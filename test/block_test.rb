require_relative "test_helper"
class TestSparxBlocks < Minitest::Test
  
  def test_inline_code
    input = "`inline code`"
    output = Sparx.parse(input)
    assert_match /<code>inline code<\/code>/, output
  end

  def test_fenced_code
    input = <<~TXT
      ```javascript
      console.log("multiline code");
      ```
    TXT
    output = Sparx.parse(input)
    assert_match %r{<pre><code class="language-javascript">console\.log\("multiline code"\);</code></pre>}, output
  end

  # ============= HEADING TESTS =============
  
  def test_all_heading_levels
    input = <<~TXT
      # Main Title
      
      Some content here.
      
      ## Chapter Heading
      
      More content.
      
      ### Section Heading
      
      #### Subsection Heading
      
      ##### Sub-subsection Heading
      
      ###### Deep Level Heading
      
      Final paragraph.
    TXT
    
    output = Sparx.parse(input)
    
    assert_match /<h1>Main Title<\/h1>/, output
    assert_match /<h2>Chapter Heading<\/h2>/, output  
    assert_match /<h3>Section Heading<\/h3>/, output
    assert_match /<h4>Subsection Heading<\/h4>/, output
    assert_match /<h5>Sub-subsection Heading<\/h5>/, output
    assert_match /<h6>Deep Level Heading<\/h6>/, output
    
    assert_match /<p>Some content here\.<\/p>/, output
    assert_match /<p>More content\.<\/p>/, output
    assert_match /<p>Final paragraph\.<\/p>/, output
  end

  def test_headings_with_formatting
    input = <<~TXT
      # *[Bold] and /[italic] title
      ## Title with `code` snippet
      ### Title with [link]https://example.com
    TXT
    
    output = Sparx.parse(input)
    
    assert_match /<h1><strong>Bold<\/strong> and <em>italic<\/em> title<\/h1>/, output
    assert_match /<h2>Title with <code>code<\/code> snippet<\/h2>/, output
    assert_match /<h3>Title with <a href="https:\/\/example\.com">link<\/a><\/h3>/, output
  end

  def test_invalid_heading_levels
    input = <<~TXT
      ####### Should not be heading
      ######## Should not be heading
    TXT
    
    output = Sparx.parse(input)
    
    # These should remain as regular text, not headings
    refute_match /<h7>/, output  
    refute_match /<h8>/, output
    assert_match /####### Should not be heading/, output
    assert_match /######## Should not be heading/, output
  end

  # ============= MISC INLINE TESTS =============
  
  def test_small_text
    input = "s[small text]"
    output = Sparx.parse(input)
    assert_match /<small>small text<\/small>/, output
  end

  def test_span_with_class
    input = ".highlight[highlighted text]"
    output = Sparx.parse(input)
    assert_match /<span class="highlight">highlighted text<\/span>/, output
  end

  # ============= TABLE TESTS =============
  
  def test_table
    input = <<~TXT
      |Header 1|Header 2|
      |--------|--------|
      |Cell 1|Cell 2|
      |Cell 3|Cell 4|
    TXT
    output = Sparx.parse(input)
    assert_match %r{<table>.*<th>Header 1<\/th>.*<th>Header 2<\/th>.*<td>Cell 1<\/td>.*<td>Cell 2<\/td>.*<td>Cell 3<\/td>.*<td>Cell 4<\/td>.*</table>}m, output
  end

  # ============= PARAGRAPH TESTS =============
  
  def test_paragraph_wrapping_with_double_newlines
    input = "First paragraph.\n\nSecond paragraph."
    output = Sparx.parse(input)
    assert_match /<p>First paragraph\.<\/p>\n\n<p>Second paragraph\.<\/p>/, output
  end

  def test_no_paragraph_wrapping_single_newlines
    input = "Single line text."
    output = Sparx.parse(input)
    assert_equal "Single line text.", output
  end

  def test_block_elements_not_wrapped_in_paragraphs
    input = <<~TXT
      # Heading

      Normal text that should be wrapped.
    TXT
    output = Sparx.parse(input)
    refute_match /<p><h1>/, output
    assert_match /<p>Normal text that should be wrapped\.<\/p>/, output
  end

  # ============= CITATION TESTS =============
  
  def test_citation_basic
    input = <<~TXT
      Check out [GitHub]@github.
      
      @github: https://github.com
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="https://github.com">GitHub</a>}, output
  end

  def test_citation_with_title
    input = <<~TXT
      Visit [Example]@example.
      
      @example: https://example.com "Example Website"
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="https://example.com" title="Example Website">Example</a>}, output
  end

  def test_citation_with_formatting
    input = <<~TXT
      Read the *[bold docs]@docs.
      
      @docs: /documentation
    TXT
    output = Sparx.parse(input)
    assert_match %r{<strong><a href="/documentation">bold docs</a></strong>}, output
  end

  def test_multiple_citations
    input = <<~TXT
      Check [GitHub]@gh and [docs]@local.
      
      @gh: https://github.com
      @local: /docs "Local Documentation"
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="https://github.com">GitHub</a>}, output
    assert_match %r{<a href="/docs" title="Local Documentation">docs</a>}, output
  end

  def test_numbered_citation_basic
    input = <<~TXT
      This is proven research[cited text]:1.
      
      1[Study Title]https://study.com
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="#cite-1">cited text<sup>1</sup></a>}, output
    assert_match %r{<cite id="cite-1"><span class="cite-number">1</span> <a href="https://study.com">Study Title</a></cite>}, output
  end

  def test_numbered_citation_with_description
    input = <<~TXT
      This research[supports the claim]:1.
      
      1[Important Study]https://journal.org "A groundbreaking study"
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="#cite-1">supports the claim<sup>1</sup></a>}, output
    assert_match %r{<a href="https://journal.org" title="A groundbreaking study">Important Study</a>}, output
  end

  def test_multiple_numbered_citations
    input = <<~TXT
      First claim[research]:1 and second claim[more research]:2.
      
      1[Study One]https://study1.com
      2[Study Two]https://study2.com "Second study"
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="#cite-1">research<sup>1</sup></a>}, output
    assert_match %r{<a href="#cite-2">more research<sup>2</sup></a>}, output
    assert_match %r{<section class="citations">}, output
  end

  def test_numbered_citation_with_formatting
    input = <<~TXT
      This *[bold research]:1 is important.
      
      1[Bold Study]https://bold.com
    TXT
    output = Sparx.parse(input)
    assert_match %r{<strong><a href="#cite-1">bold research<sup>1</sup></a></strong>}, output
  end

  def test_mixed_citation_systems
    input = <<~TXT
      Named citation[GitHub]@github and numbered[research]:1.
      
      @github: https://github.com
      1[Study]https://study.com
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="https://github.com">GitHub</a>}, output
    assert_match %r{<a href="#cite-1">research<sup>1</sup></a>}, output
  end

  # ============= IMAGE TESTS =============
  
  def test_image_basic
    input = "i[Mountain view]image.jpg"
    output = Sparx.parse(input)
    assert_match /<img src="image\.jpg" alt="Mountain view">/, output
  end

  def test_image_with_title
    input = "i[Mountain view|Beautiful sunset]image.jpg"
    output = Sparx.parse(input)
    assert_match /<img src="image\.jpg" alt="Mountain view" title="Beautiful sunset">/, output
  end

  def test_image_with_dimensions
    input = "i[Mountain view]image.jpg=320x280"
    output = Sparx.parse(input)
    assert_match /<img src="image\.jpg" alt="Mountain view" width="320" height="280">/, output
  end

  def test_image_with_url_prefix
    input = <<~TXT
      i[Mountain view]@cdn/image.jpg
      
      @cdn: https://cdn.example.com/images/
    TXT
    output = Sparx.parse(input)
    assert_match /<img src="https:\/\/cdn\.example\.com\/images\/image\.jpg" alt="Mountain view">/, output
  end

  def test_image_with_all_features
    input = <<~TXT
      i[Mountain view|Beautiful sunset]@cdn/image.jpg=320x280
      
      @cdn: https://cdn.example.com/images/
    TXT
    output = Sparx.parse(input)
    expected = /<img src="https:\/\/cdn\.example\.com\/images\/image\.jpg" alt="Mountain view" title="Beautiful sunset" width="320" height="280">/
    assert_match expected, output
  end

  def test_image_with_formatting_prefix
    input = "*i[Bold image]image.jpg"
    output = Sparx.parse(input)
    assert_match /<strong><img src="image\.jpg" alt="Bold image"><\/strong>/, output
  end
end