require_relative "test_helper"

class TestSparxIntegration < Minitest::Test
  
  def test_full_integration
    input = <<~TXT
      # Main Document
      
      $[intro]{
        ## Introduction
        
        Welcome to *[Sparx], a /[powerful] markup language.
        
        >{
          "The best markup language I've ever used!"
          - Someone important
        }
      }
      
      $[features]{
        ## Features
        
        .highlight{
          ### Key Features:
          - Easy to learn
          - Powerful containers
          - Full nesting support
        }
        
        ~{
          **Note:** This is still in development.
          
          f[Figure 1: Architecture]{
            i[System diagram]architecture.png
            
            The system uses a recursive parser.
          }
        }
        
        +[Advanced Features]{
          >[https://docs.example.com]{
            Our documentation covers:
            
            + Container nesting
            + Citation systems
            + Image embedding
          }
        }
      }
      
      ## References
      
      See [our website]@site for more info, and check the studies[research papers]:1.
      
      @site: https://example.com "Example Site"
      1[Sparx Paper]https://research.com/sparx "The original paper"
      
      |Feature|Status|
      |--------|------|
      |Containers|✓|
      |Nesting|✓|
      
      ```ruby
      puts "Sparx rocks!"
      ```
      
      That's all for now. Visit [GitHub]https://github.com/sparx^ for the source.
      
      i[Logo|Sparx Logo]logo.png=200x50
    TXT
    
    output = Sparx.parse(input)
    
    # Main structure
    assert_match /<h1>Main Document<\/h1>/, output
    assert_match /<section id="intro">/, output
    assert_match /<section id="features">/, output
    
    # Containers
    assert_match /<blockquote>/, output
    assert_match /<div class="highlight">/, output
    assert_match /<aside>/, output
    assert_match /<figure>/, output
    assert_match /<details>/, output
    
    # Nested blockquote with cite
    assert_match /<blockquote cite="https:\/\/docs\.example\.com">/, output
    
    # Figure with caption
    assert_match /<figcaption>Figure 1: Architecture<\/figcaption>/, output
    
    # Formatting
    assert_match /<strong>Sparx<\/strong>/, output
    assert_match /<em>powerful<\/em>/, output
    
    # Lists
    assert_match /<ul>.*<li>Easy to learn<\/li>.*<\/ul>/m, output
    assert_match /<ol>.*<li>Container nesting<\/li>.*<\/ol>/m, output
    
    # Citations
    assert_match /<a href="https:\/\/example\.com" title="Example Site">our website<\/a>/, output
    assert_match /<a href="#cite-1">research papers<sup>1<\/sup><\/a>/, output
    assert_match /<cite id="cite-1">/, output
    
    # Table
    assert_match /<table>/, output
    assert_match /<th>Feature<\/th>/, output
    assert_match /<td>✓<\/td>/, output
    
    # Code
    assert_match /<pre><code class="language-ruby">puts "Sparx rocks!"<\/code><\/pre>/, output
    
    # Link with target
    assert_match /<a href="https:\/\/github\.com\/sparx" target="_blank">GitHub<\/a>/, output
    
    # Image with dimensions
    assert_match /<img src="logo\.png" alt="Logo" title="Sparx Logo" width="200" height="50">/, output
  end
end