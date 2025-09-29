require_relative "test_helper"
class TestSparxLists < Minitest::Test

  
  def test_unordered_lists
    input = <<~TXT
      - first item
      - second item
      - third item
    TXT
    output = Sparx.parse(input)
    assert_match /<ul><li>first item<\/li><li>second item<\/li><li>third item<\/li><\/ul>/, output
  end

  def test_ordered_lists
    input = <<~TXT
      + first item
      + second item
      + third item
    TXT
    output = Sparx.parse(input)
    assert_match /<ol><li>first item<\/li><li>second item<\/li><li>third item<\/li><\/ol>/, output
  end

  def test_nested_unordered_lists
    input = <<~TXT
      - first item
      -- nested item
      -- another nested item
      --- deeply nested
      - back to top level
    TXT
    output = Sparx.parse(input)
    expected = /<ul><li>first item<ul><li>nested item<\/li><li>another nested item<ul><li>deeply nested<\/li><\/ul><\/li><\/ul><\/li><li>back to top level<\/li><\/ul>/
    assert_match expected, output
  end

  def test_nested_ordered_lists
    input = <<~TXT
      + first item
      ++ nested item
      ++ another nested item
      +++ deeply nested
      + back to top level
    TXT
    output = Sparx.parse(input)
    expected = /<ol><li>first item<ol><li>nested item<\/li><li>another nested item<ol><li>deeply nested<\/li><\/ol><\/li><\/ol><\/li><li>back to top level<\/li><\/ol>/
    assert_match expected, output
  end
    def test_nested_unordered_list
    input = <<~TXT
      - first item
      -- nested item
      -- another nested
      --- deep nested
      - back to top
    TXT
    output = Sparx.parse(input)
    expected = %r{<ul><li>first item<ul><li>nested item</li><li>another nested<ul><li>deep nested</li></ul></li></ul></li><li>back to top</li></ul>}
    assert_match expected, output
  end

  def test_list_with_block_heading
    input = <<~TXT
      - item one
      -{
        ## Header in List
      }
      - item two
    TXT
    output = Sparx.parse(input)
    assert_match %r{<ul><li>item one</li><li><h2>Header in List</h2></li><li>item two</li></ul>}, output
  end

  def test_complex_list_with_paragraphs
    input = <<~TXT
      -{
        First paragraph in list.
        
        Second paragraph in list.
      }
      - simple item
    TXT
    output = Sparx.parse(input)
    assert_match %r{<ul><li><p>First paragraph in list\.</p>\n\n<p>Second paragraph in list\.</p></li><li>simple item</li></ul>}, output
  end

  def test_nested_list_with_block
    input = <<~TXT
      - top item
      --{
        ## Nested Header
        
        Content under header.
      }
      - another top
    TXT
    output = Sparx.parse(input)
    assert_match %r{<ul><li>top item<ul><li><h2>Nested Header</h2>\n\n<p>Content under header\.</p></li></ul></li><li>another top</li></ul>}, output
  end

  def test_list_interrupted_by_paragraph
    input = <<~TXT
      - item one
      - item two
      
      Paragraph after list.
    TXT
    output = Sparx.parse(input)
    assert_match %r{<ul><li>item one</li><li>item two</li></ul>\n\n<p>Paragraph after list\.</p>}, output
  end

  def test_mixed_simple_and_complex
    input = <<~TXT
      - simple item
      -{
        Complex item with *[formatting]
        
        And multiple paragraphs
      }
      -- nested simple
      --{
        Nested complex
      }
    TXT
    output = Sparx.parse(input)
    assert_match /<ul>/, output
    assert_match /<strong>formatting<\/strong>/, output
    assert_match /And multiple paragraphs/, output
    assert_match /Nested complex/, output
  end

  def test_ordered_with_complex
    input = <<~TXT
      + Step one
      +{
        ## Step Two
        
        With details
      }
      ++ Sub-step
    TXT
    output = Sparx.parse(input)
    assert_match /<ol>/, output
    assert_match /<h2>Step Two<\/h2>/, output
    assert_match /Sub-step/, output
  end

  def test_mixed_elements
    input = <<~TXT
      ## Main Header
      
      Paragraph with *[bold] and /[italic].
      
      - List item
      -{
        ## Subheader in list
        
        With a [link]https://example.com
      }
      
      Another paragraph.
    TXT
    output = Sparx.parse(input)
    assert_match /<h2>Main Header<\/h2>/, output
    assert_match /<p>Paragraph with <strong>bold<\/strong> and <em>italic<\/em>\.<\/p>/, output
    assert_match /<ul><li>List item<\/li><li><h2>Subheader in list<\/h2>/, output
    assert_match /<a href="https:\/\/example\.com">link<\/a>/, output
    assert_match /<p>Another paragraph\.<\/p>/, output
  end

  def test_code_in_list
    input = <<~TXT
      - Item with `inline code`
      -{
        ## Complex item
        
        With `more code`
      }
    TXT
    output = Sparx.parse(input)
    assert_match /<code>inline code<\/code>/, output
    assert_match /<code>more code<\/code>/, output
  end

  # ========= DEFINITION LISTS ===========

    def test_simple_definition_list
    input = <<~TXT
      :term one: definition one
      :term two: definition two
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dl><dt>term one</dt><dd>definition one</dd><dt>term two</dt><dd>definition two</dd></dl>}, output
  end

  def test_definition_with_inline_formatting
    input = <<~TXT
      :*[bold term]: definition with /[italic] text
      :regular term: definition with `code`
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt><strong>bold term</strong></dt>}, output
    assert_match %r{<dd>definition with <em>italic</em> text</dd>}, output
    assert_match %r{<dd>definition with <code>code</code></dd>}, output
  end

  def test_complex_definition_with_block_content
    input = <<~TXT
      :simple term: simple definition
      :complex term:{
        ## Header in Definition
        
        Multiple paragraphs work here too.
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>simple term</dt><dd>simple definition</dd>}, output
    assert_match %r{<dt>complex term</dt><dd><h2>Header in Definition</h2>}, output
    assert_match %r{<p>Multiple paragraphs work here too\.</p></dd>}, output
  end

  def test_nested_definition_lists
    input = <<~TXT
      :main term: main definition
      ::nested term: nested definition
      ::another nested: another nested definition
      :back to main: back to main level
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dl>}, output
    assert_match %r{<dt>main term</dt><dd>main definition<dl>}, output
    assert_match %r{<dt>nested term</dt><dd>nested definition</dd>}, output
    assert_match %r{<dt>another nested</dt><dd>another nested definition</dd></dl></dd>}, output
    assert_match %r{<dt>back to main</dt><dd>back to main level</dd></dl>}, output
  end

  def test_nested_definition_with_complex_content
    input = <<~TXT
      :main term: main definition
      ::nested term:{
        ## Nested Header
        
        Content in nested definition.
      }
      :another main: another main term
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>main term</dt><dd>main definition<dl>}, output
    assert_match %r{<dt>nested term</dt><dd><h2>Nested Header</h2>}, output
    assert_match %r{<p>Content in nested definition\.</p></dd></dl></dd>}, output
    assert_match %r{<dt>another main</dt><dd>another main term</dd>}, output
  end

  def test_deep_nesting_definitions
    input = <<~TXT
      :level one: definition one
      ::level two: definition two
      :::level three: definition three
      ::back to two: back to level two
      :back to one: back to level one
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dl><dt>level one</dt><dd>definition one<dl>}, output
    assert_match %r{<dt>level two</dt><dd>definition two<dl>}, output
    assert_match %r{<dt>level three</dt><dd>definition three</dd></dl>}, output
    assert_match %r{<dt>back to two</dt><dd>back to level two</dd></dl></dd>}, output
    assert_match %r{<dt>back to one</dt><dd>back to level one</dd></dl>}, output
  end

  def test_mixed_simple_and_complex_definitions
    input = <<~TXT
      :simple: just text here
      :complex:{
        Multiple paragraphs here.
        
        With *[formatting] too!
      }
      ::nested simple: nested text
      ::nested complex:{
        ## Nested heading
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>simple</dt><dd>just text here</dd>}, output
    assert_match %r{<dt>complex</dt><dd><p>Multiple paragraphs here\.</p>}, output
    assert_match %r{<p>With <strong>formatting</strong> too!</p></dd>}, output
    assert_match %r{<dt>nested simple</dt><dd>nested text</dd>}, output
    assert_match %r{<dt>nested complex</dt><dd><h2>Nested heading</h2></dd>}, output
  end

  def test_definition_list_with_links
    input = <<~TXT
      :web term: see [example]https://example.com for details
      :citation term:{
        More info at [research paper]https://research.example.com
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<a href="https://example\.com">example</a>}, output
    assert_match %r{<a href="https://research\.example\.com">research paper</a>}, output
  end

  def test_definition_list_interrupted_by_paragraph
    input = <<~TXT
      :term one: definition one
      :term two: definition two
      
      This paragraph interrupts the definition list.
      
      :new term: this starts a new definition list
    TXT
    output = Sparx.parse(input)
    # Should create two separate definition lists
    assert_match %r{<dl><dt>term one</dt><dd>definition one</dd><dt>term two</dt><dd>definition two</dd></dl>}, output
    assert_match %r{<p>This paragraph interrupts the definition list\.</p>}, output
    assert_match %r{<dl><dt>new term</dt><dd>this starts a new definition list</dd></dl>}, output
  end

  def test_definition_with_code_blocks
    input = <<~TXT
      :code example:{
        Here's some code:
        
        ```ruby
        puts "hello world"
        ```
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>code example</dt>}, output
    assert_match %r{<pre><code class="language-ruby">puts "hello world"</code></pre>}, output
  end

  def test_empty_definition_handling
    input = <<~TXT
      :term with empty def: 
      :normal term: normal definition
    TXT
    output = Sparx.parse(input)
    # Should handle empty definitions gracefully
    assert_match %r{<dt>term with empty def</dt><dd></dd>}, output
    assert_match %r{<dt>normal term</dt><dd>normal definition</dd>}, output
  end

  def test_mixed_with_other_elements
    input = <<~TXT
      # Main Heading
      
      Some introductory text.
      
      :definition term: definition text
      :another term:{
        ## Sub-heading
        
        - List in definition
        - Another list item
      }
      
      Final paragraph.
    TXT
    output = Sparx.parse(input)
    assert_match %r{<h1>Main Heading</h1>}, output
    assert_match %r{<p>Some introductory text\.</p>}, output
    assert_match %r{<dl><dt>definition term</dt><dd>definition text</dd>}, output
    assert_match %r{<dt>another term</dt><dd><h2>Sub-heading</h2>}, output
    assert_match %r{<ul><li>List in definition</li><li>Another list item</li></ul>}, output
    assert_match %r{<p>Final paragraph\.</p>}, output
  end

  def test_definition_with_containers
    input = <<~TXT
      :container example:{
        >{
          This is a blockquote in a definition.
        }
        
        ~{
          This is an aside in a definition.
        }
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>container example</dt>}, output
    assert_match %r{<blockquote>This is a blockquote in a definition\.</blockquote>}, output
    assert_match %r{<aside>This is an aside in a definition\.</aside>}, output
  end

  def test_whitespace_handling
    input = <<~TXT
      :  term with spaces  :  definition with spaces  
      :another:{
        
        Content with leading/trailing whitespace
        
      }
    TXT
    output = Sparx.parse(input)
    assert_match %r{<dt>term with spaces</dt><dd>definition with spaces</dd>}, output
    assert_match %r{<dt>another</dt><dd><p>Content with leading/trailing whitespace</p></dd>}, output
  end
end