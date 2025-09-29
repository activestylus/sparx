require_relative "test_helper"
class TestSparxContainers < Minitest::Test

  def test_simple_srcset
    input = 'i[Responsive]img.jpg 320w|img@2x.jpg 640w|img@3x.jpg 1920w'
    output = Sparx.parse(input)
    assert_match /<img src="img\.jpg" srcset="img\.jpg 320w, img@2x\.jpg 640w, img@3x\.jpg 1920w" alt="Responsive">/, output
  end

  def test_simple_srcset_without_descriptors
    input = 'i[Image]small.jpg|medium.jpg|large.jpg'
    output = Sparx.parse(input)
    assert_match /<img src="small\.jpg" srcset="small\.jpg, medium\.jpg, large\.jpg" alt="Image">/, output
  end

  def test_picture_element_basic
    input = <<~TXT
      src[>800px]desktop.jpg
      src[>400px]tablet.jpg
      i[Hero]mobile.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<picture>/, output
    assert_match /<source srcset="desktop\.jpg" type="image\/jpeg" media="\(min-width: 800px\)">/, output
    assert_match /<source srcset="tablet\.jpg" type="image\/jpeg" media="\(min-width: 400px\)">/, output
    assert_match /<img src="mobile\.jpg" alt="Hero">/, output
    assert_match /<\/picture>/, output
  end

  def test_picture_element_with_max_width
    input = <<~TXT
      src[<600px]mobile.jpg
      i[Responsive]desktop.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<source srcset="mobile\.jpg" type="image\/jpeg" media="\(max-width: 600px\)">/, output
  end

  def test_picture_with_format_switching
    input = <<~TXT
      src[>800px]hero.{webp,jpg}
      i[Hero]hero-mobile.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<picture>/, output
    assert_match /<source srcset="hero\.webp" type="image\/webp" media="\(min-width: 800px\)">/, output
    assert_match /<source srcset="hero\.jpg" type="image\/jpeg" media="\(min-width: 800px\)">/, output
    assert_match /<img src="hero-mobile\.jpg" alt="Hero">/, output
  end

  def test_picture_with_srcset_and_brace_expansion
    input = <<~TXT
      src[>800px]img.{webp,jpg} 800w|img-2x.{webp,jpg} 1600w
      i[Responsive]fallback.jpg
    TXT
    output = Sparx.parse(input)
    # Should group by type
    assert_match /<source srcset="img\.webp 800w, img-2x\.webp 1600w" type="image\/webp" media="\(min-width: 800px\)">/, output
    assert_match /<source srcset="img\.jpg 800w, img-2x\.jpg 1600w" type="image\/jpeg" media="\(min-width: 800px\)">/, output
  end

  def test_picture_with_avif_webp_jpg
    input = <<~TXT
      src[>1024px]hero.{avif,webp,jpg}
      i[Hero Image]hero-mobile.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<source srcset="hero\.avif" type="image\/avif" media="\(min-width: 1024px\)">/, output
    assert_match /<source srcset="hero\.webp" type="image\/webp" media="\(min-width: 1024px\)">/, output
    assert_match /<source srcset="hero\.jpg" type="image\/jpeg" media="\(min-width: 1024px\)">/, output
  end

  def test_src_without_img_left_as_is
    input = <<~TXT
      src[>800px]orphan.jpg
      
      Some other content here.
    TXT
    output = Sparx.parse(input)
    # Should leave src[] visible for debugging
    assert_match /src\[>800px\]orphan\.jpg/, output
  end

  def test_non_contiguous_src_dont_group
    input = <<~TXT
      src[>800px]desktop.jpg
      
      Some text interrupts
      
      i[Hero]mobile.jpg
    TXT
    output = Sparx.parse(input)
    # Should not create picture element
    refute_match /<picture>/, output
    # src should be left as-is
    assert_match /src\[>800px\]desktop\.jpg/, output
    # img should still process normally
    assert_match /<img src="mobile\.jpg" alt="Hero">/, output
  end

  def test_single_blank_line_allows_grouping
    input = <<~TXT
      src[>800px]desktop.jpg
      src[>400px]tablet.jpg

      i[Hero]mobile.jpg
    TXT
    output = Sparx.parse(input)
    # Should still create picture element
    assert_match /<picture>/, output
    assert_match /<source srcset="desktop\.jpg"/, output
  end

  def test_picture_preserves_image_dimensions
    input = <<~TXT
      src[>800px]desktop.jpg
      i[Hero]mobile.jpg=800x600
    TXT
    output = Sparx.parse(input)
    assert_match /<img src="mobile\.jpg" alt="Hero" width="800" height="600">/, output
  end

  def test_picture_preserves_image_title
    input = <<~TXT
      src[>800px]desktop.jpg
      i[Hero|Beautiful landscape]mobile.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<img src="mobile\.jpg" alt="Hero" title="Beautiful landscape">/, output
  end

  def test_picture_with_url_prefix
    input = <<~TXT
      src[>800px]@cdn/desktop.jpg
      i[Hero]@cdn/mobile.jpg
      
      @cdn: https://cdn.example.com/images/
    TXT
    output = Sparx.parse(input)
    assert_match /<source srcset="https:\/\/cdn\.example\.com\/images\/desktop\.jpg"/, output
    assert_match /<img src="https:\/\/cdn\.example\.com\/images\/mobile\.jpg"/, output
  end

  def test_picture_with_formatting_prefix
    input = <<~TXT
      src[>800px]desktop.jpg
      *i[Bold hero]mobile.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /<strong><picture>/, output
    assert_match /<\/picture><\/strong>/, output
  end

  def test_picture_inside_figure
    input = <<~TXT
      f[Responsive Hero Image]{
        src[>800px]hero-large.jpg
        src[>400px]hero-medium.jpg
        i[Hero]hero-small.jpg
      }
    TXT
    output = Sparx.parse(input)
    assert_match /<figure>/, output
    assert_match /<picture>/, output
    assert_match /<figcaption>Responsive Hero Image<\/figcaption>/, output
  end

  def test_multiple_picture_elements
    input = <<~TXT
      src[>800px]hero1-large.jpg
      i[Hero 1]hero1-small.jpg
      
      Some text between images.
      
      src[>800px]hero2-large.jpg
      i[Hero 2]hero2-small.jpg
    TXT
    output = Sparx.parse(input)
    # Should create two separate picture elements
    assert_equal 2, output.scan(/<picture>/).length
    assert_match /<img src="hero1-small\.jpg" alt="Hero 1">/, output
    assert_match /<img src="hero2-small\.jpg" alt="Hero 2">/, output
  end

  def test_existing_image_behavior_preserved
    input = 'i[Logo]logo.png=150x50'
    output = Sparx.parse(input)
    assert_match /<img src="logo\.png" alt="Logo" width="150" height="50">/, output
    refute_match /<picture>/, output
  end

  def test_type_inference_all_formats
    input = <<~TXT
      src[>1024px]img.{avif,webp,png,gif,svg,jpg}
      i[All formats]fallback.jpg
    TXT
    output = Sparx.parse(input)
    assert_match /type="image\/avif"/, output
    assert_match /type="image\/webp"/, output
    assert_match /type="image\/png"/, output
    assert_match /type="image\/gif"/, output
    assert_match /type="image\/svg\+xml"/, output
    assert_match /type="image\/jpeg"/, output
  end

  def test_complex_responsive_in_article
    input = <<~TXT
      # Responsive Images Article
      
      $[hero]{
        src[>1024px]hero.{avif,webp,jpg} 1024w|hero-2x.{avif,webp,jpg} 2048w
        src[>768px]hero-tablet.{avif,webp,jpg}
        i[Hero Image|Main article hero]hero-mobile.jpg
      }
      
      Article content here.
    TXT
    output = Sparx.parse(input)
    assert_match /<h1>Responsive Images Article<\/h1>/, output
    assert_match /<section id="hero">/, output
    assert_match /<picture>/, output
    assert_match /srcset="hero\.avif 1024w, hero-2x\.avif 2048w"/, output
    assert_match /<p>Article content here\.<\/p>/, output
  end
end