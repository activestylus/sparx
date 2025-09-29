require_relative "test_helper"
class TestSparxContainers < Minitest::Test
  
  
  # Basic container tests for all types
  CONTAINER_TESTS = {
    section: {
      input: '$[test]{Content inside section}',
      expected: /<section id="test">Content inside section<\/section>/
    },
    blockquote_without_cite: {
      input: '>{Content inside blockquote}',
      expected: /<blockquote>Content inside blockquote<\/blockquote>/
    },
    blockquote_with_cite: {
      input: '>[https://example.com]{Quoted content}',
      expected: /<blockquote cite="https:\/\/example\.com">Quoted content<\/blockquote>/
    },
    div_class: {
      input: '.warning{Content inside div}',
      expected: /<div class="warning">Content inside div<\/div>/
    },
    aside: {
      input: '~{Content inside aside}',
      expected: /<aside>Content inside aside<\/aside>/
    },
    figure: {
      input: 'f[Figure 1: Test]{Content inside figure}',
      expected: /<figure>Content inside figure<figcaption>Figure 1: Test<\/figcaption><\/figure>/
    },
    details: {
      input: '+[Click to expand]{Hidden content}',
      expected: /<details><summary>Click to expand<\/summary>Hidden content<\/details>/
    }
  }

  CONTAINER_TESTS.each do |name, test_data|
    define_method "test_container_#{name}" do
      output = Sparx.parse(test_data[:input])
      assert_match test_data[:expected], output, 
        "Container #{name} failed. Input: #{test_data[:input]}"
    end
  end

  # Test that ALL containers handle nested content properly
  CONTAINER_SYNTAXES = {
    section: '$[id]{CONTENT}',
    blockquote: '>{CONTENT}',
    div_class: '.classname{CONTENT}',
    aside: '~{CONTENT}',
    figure: 'f[caption]{CONTENT}',
    details: '+[summary]{CONTENT}'
  }

  CONTAINER_SYNTAXES.each do |type, syntax|
    define_method "test_#{type}_handles_formatting" do
      input = syntax.sub('CONTENT', '*[bold] and /[italic] text')
      output = Sparx.parse(input)
      assert_match /<strong>bold<\/strong>/, output
      assert_match /<em>italic<\/em>/, output
    end

    define_method "test_#{type}_handles_paragraphs" do
      input = syntax.sub('CONTENT', "First paragraph.\n\nSecond paragraph.")
      output = Sparx.parse(input)
      assert_match /<p>First paragraph\.<\/p>/, output
      assert_match /<p>Second paragraph\.<\/p>/, output
    end

    define_method "test_#{type}_handles_lists" do
      input = syntax.sub('CONTENT', "- item one\n- item two")
      output = Sparx.parse(input)
      assert_match /<ul><li>item one<\/li><li>item two<\/li><\/ul>/, output
    end

    define_method "test_#{type}_handles_headings" do
      input = syntax.sub('CONTENT', "## Heading inside #{type}")
      output = Sparx.parse(input)
      assert_match /<h2>Heading inside #{type}<\/h2>/, output
    end
  end

  # ============= DEEP NESTING TESTS =============
  
  def test_section_inside_section
    input = "$[outer]{## Outer\n\n$[inner]{### Inner content}}"
    output = Sparx.parse(input)
    assert_match /<section id="outer">/, output
    assert_match /<section id="inner">/, output
    assert_match /<h2>Outer<\/h2>/, output
    assert_match /<h3>Inner content<\/h3>/, output
  end

  def test_blockquote_inside_section
    input = '$[main]{>{This is a quote inside a section}}'
    output = Sparx.parse(input)
    assert_match /<section id="main"><blockquote>This is a quote inside a section<\/blockquote><\/section>/, output
  end

  def test_section_inside_blockquote
    input = '>{$[quoted]{Content in quoted section}}'
    output = Sparx.parse(input)
    assert_match /<blockquote><section id="quoted">Content in quoted section<\/section><\/blockquote>/, output
  end

  def test_details_inside_div
    input = '.container{+[Expandable]{Hidden content inside div}}'
    output = Sparx.parse(input)
    assert_match /<div class="container"><details><summary>Expandable<\/summary>Hidden content inside div<\/details><\/div>/, output
  end

  def test_figure_inside_aside
    input = '~{f[Chart 1]{i[Data visualization]chart.png}}'
    output = Sparx.parse(input)
    assert_match /<aside><figure><img src="chart\.png" alt="Data visualization"><figcaption>Chart 1<\/figcaption><\/figure><\/aside>/, output
  end

  def test_triple_nesting
    input = '$[outer]{.warning{~{Deeply nested content}}}'
    output = Sparx.parse(input)
    assert_match /<section id="outer"><div class="warning"><aside>Deeply nested content<\/aside><\/div><\/section>/, output
  end

  def test_complex_nesting_with_mixed_content
    input = <<~TXT
      $[article]{
        ## Main Title
        
        >{
          A quote with *[emphasis]
          
          $[note]{
            ### Note inside quote
            With a [link]https://example.com
          }
        }
        
        .highlight{
          Important information
          
          - First point
          - Second point
        }
      }
    TXT
    output = Sparx.parse(input)
    
    # Verify structure is preserved
    assert_match /<section id="article">/, output
    assert_match /<h2>Main Title<\/h2>/, output
    assert_match /<blockquote>/, output
    assert_match /<strong>emphasis<\/strong>/, output
    assert_match /<section id="note">/, output
    assert_match /<h3>Note inside quote<\/h3>/, output
    assert_match /<div class="highlight">/, output
    assert_match /<ul><li>First point<\/li><li>Second point<\/li><\/ul>/, output
  end

  # ============= BLOCKQUOTE WITH CITE TESTS =============
  
  def test_blockquote_with_http_cite
    input = '>[http://example.com/source]{Quote with HTTP cite}'
    output = Sparx.parse(input)
    assert_match /<blockquote cite="http:\/\/example\.com\/source">Quote with HTTP cite<\/blockquote>/, output
  end

  def test_blockquote_with_https_cite
    input = '>[https://secure.example.com]{Quote with HTTPS cite}'
    output = Sparx.parse(input)
    assert_match /<blockquote cite="https:\/\/secure\.example\.com">Quote with HTTPS cite<\/blockquote>/, output
  end

  def test_blockquote_with_relative_cite
    input = '>[/articles/source]{Quote with relative cite}'
    output = Sparx.parse(input)
    assert_match /<blockquote cite="\/articles\/source">Quote with relative cite<\/blockquote>/, output
  end

  def test_blockquote_without_cite
    input = '>{Simple quote without citation}'
    output = Sparx.parse(input)
    assert_match /<blockquote>Simple quote without citation<\/blockquote>/, output
  end

  # ============= DIV WITH CLASS TESTS =============
  
  def test_div_with_simple_class
    input = '.alert{Alert message}'
    output = Sparx.parse(input)
    assert_match /<div class="alert">Alert message<\/div>/, output
  end

  def test_div_with_hyphenated_class
    input = '.my-custom-class{Content}'
    output = Sparx.parse(input)
    assert_match /<div class="my-custom-class">Content<\/div>/, output
  end

  def test_div_with_underscore_class
    input = '.header_section{Header content}'
    output = Sparx.parse(input)
    assert_match /<div class="header_section">Header content<\/div>/, output
  end

  # ============= ASIDE TESTS =============
  
  def test_aside_basic
    input = '~{This is an aside}'
    output = Sparx.parse(input)
    assert_match /<aside>This is an aside<\/aside>/, output
  end

  def test_aside_with_complex_content
    input = <<~TXT
      ~{
        ## Side Note
        
        This is tangential information with *[emphasis].
        
        - Point A
        - Point B
      }
    TXT
    output = Sparx.parse(input)
    assert_match /<aside>/, output
    assert_match /<h2>Side Note<\/h2>/, output
    assert_match /<strong>emphasis<\/strong>/, output
    assert_match /<ul>/, output
  end

  # ============= FIGURE TESTS =============
  
  def test_figure_basic
    input = 'f[Figure 1]{i[Chart]chart.png}'
    output = Sparx.parse(input)
    assert_match /<figure><img src="chart\.png" alt="Chart"><figcaption>Figure 1<\/figcaption><\/figure>/, output
  end

  def test_figure_with_formatted_caption
    input = 'f[*[Important] Figure]{Content}'
    output = Sparx.parse(input)
    assert_match /<figure>Content<figcaption><strong>Important<\/strong> Figure<\/figcaption><\/figure>/, output
  end

  def test_figure_with_multiple_elements
    input = <<~TXT
      f[Data Visualization]{
        i[Primary chart]chart1.png
        
        i[Secondary chart]chart2.png
        
        Data description here.
      }
    TXT
    output = Sparx.parse(input)
    assert_match /<figure>/, output
    assert_match /<img src="chart1\.png" alt="Primary chart">/, output
    assert_match /<img src="chart2\.png" alt="Secondary chart">/, output
    assert_match /<figcaption>Data Visualization<\/figcaption>/, output
  end
end