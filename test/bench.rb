#!/usr/bin/env ruby

require 'benchmark'
require 'benchmark/ips'
require_relative "../lib/sparx.rb"

# Competitor parsers
begin
  require 'redcarpet'
  REDCARPET_AVAILABLE = true
rescue LoadError
  REDCARPET_AVAILABLE = false
  puts "Redcarpet not available - install with: gem install redcarpet"
end

begin
  require 'kramdown'
  KRAMDOWN_AVAILABLE = true
rescue LoadError
  KRAMDOWN_AVAILABLE = false
  puts "Kramdown not available - install with: gem install kramdown"
end

begin
  require 'commonmarker'
  COMMONMARKER_AVAILABLE = true
rescue LoadError
  COMMONMARKER_AVAILABLE = false
  puts "CommonMarker not available - install with: gem install commonmarker"
end

# Test documents focusing on overlapping features
class BenchmarkDocuments
  def self.blog_post
    <<~MD
      # How to Build a Fast Parser
      
      Building a **fast parser** is both an *art* and a science. Here's what I've learned.
      
      ## Key Principles
      
      The most important things to remember:
      
      - Keep the hot path simple
      - Minimize backtracking
      - Use efficient data structures
      - Profile, don't guess
      
      ### Code Example
      
      Here's a simple tokenizer:
      
      ```ruby
      def tokenize(text)
        tokens = []
        text.scan(/\\w+/) { |match| tokens << match }
        tokens
      end
      ```
      
      ## Performance Results
      
      | Parser | Speed | Memory |
      |--------|-------|--------|
      | Fast   | 100ms | 10MB   |
      | Slow   | 500ms | 50MB   |
      
      > Performance matters more than you think.
      
      Check out the [documentation](https://example.com) for more details.
      
      **Bottom line**: measure everything, optimize intelligently.
    MD
  end
  
  def self.technical_doc
    <<~MD
      # API Reference Guide
      
      This document covers the complete API reference for our parsing library.
      
      ## Authentication
      
      ### Basic Auth
      
      ```http
      GET /api/v1/parse
      Authorization: Basic <credentials>
      ```
      
      ### Token Auth
      
      ```http 
      GET /api/v1/parse
      Authorization: Bearer <token>
      ```
      
      ## Endpoints
      
      ### Parse Text
      
      **Endpoint:** `POST /parse`
      
      **Parameters:**
      
      - `text` (string, required) - The text to parse
      - `format` (string, optional) - Output format (`html`, `json`)
      - `options` (object, optional) - Parser options
        - `strict` (boolean) - Enable strict mode
        - `features` (array) - Enabled features
          - `tables`
          - `lists`  
          - `code_blocks`
      
      **Example Request:**
      
      ```json
      {
        "text": "# Hello World\\n\\nThis is **bold** text.",
        "format": "html",
        "options": {
          "strict": true,
          "features": ["tables", "lists"]
        }
      }
      ```
      
      **Example Response:**
      
      ```json
      {
        "status": "success",
        "data": {
          "html": "<h1>Hello World</h1>\\n<p>This is <strong>bold</strong> text.</p>",
          "tokens": 15,
          "parse_time": "2.3ms"
        }
      }
      ```
      
      ### Error Handling
      
      | Status Code | Error Type | Description |
      |-------------|------------|-------------|
      | 400 | Bad Request | Invalid parameters |
      | 401 | Unauthorized | Missing auth |
      | 422 | Unprocessable | Parse failed |
      | 500 | Server Error | Internal error |
      
      #### Common Errors
      
      1. **Missing text parameter**
         - Status: 400
         - Message: "Text parameter is required"
         
      2. **Invalid format**
         - Status: 400  
         - Message: "Format must be 'html' or 'json'"
         
      3. **Parse timeout**
         - Status: 422
         - Message: "Parse operation timed out"
      
      ## Rate Limits
      
      | Plan | Requests/hour | Concurrent |
      |------|---------------|------------|
      | Free | 1,000 | 2 |
      | Pro | 10,000 | 10 |
      | Enterprise | Unlimited | 100 |
      
      > Rate limits reset at the top of each hour.
      
      ## SDKs
      
      ### Ruby
      
      ```ruby
      require 'parser_client'
      
      client = ParserClient.new(api_key: 'your_key')
      result = client.parse('# Hello **World**')
      puts result.html
      ```
      
      ### Python
      
      ```python
      from parser_client import ParserClient
      
      client = ParserClient(api_key='your_key')
      result = client.parse('# Hello **World**')  
      print(result.html)
      ```
      
      ### JavaScript
      
      ```javascript
      const ParserClient = require('parser-client');
      
      const client = new ParserClient({ apiKey: 'your_key' });
      const result = await client.parse('# Hello **World**');
      console.log(result.html);
      ```
    MD
  end
  
  def self.novel_chapter
    base_text = <<~MD
      # Chapter 1: The Beginning
      
      It was a dark and stormy night when Sarah first discovered the **mysterious letter** 
      tucked beneath her grandmother's old oak desk. The *aged parchment* crackled as she 
      unfolded it, revealing secrets that would change her life forever.
      
      ## The Discovery
      
      The letter spoke of hidden treasures and ancient mysteries. Sarah read each word 
      carefully, her heart pounding with excitement. Could this really be true? Her 
      grandmother had always been full of stories, but this felt different.
      
      She looked around the dusty attic, filled with decades of memories. Boxes of 
      photographs, old furniture covered in white sheets, and the smell of lavender 
      that seemed to follow her grandmother everywhere.
      
      > "The truth is not always what it appears to be," the letter began.
      
      Sarah continued reading, each paragraph revealing more shocking revelations about 
      her family's past. Names she had never heard, places she had never been, and 
      events that happened long before she was born.
      
      ## The Journey Begins
      
      Armed with nothing but the cryptic letter and her determination, Sarah decided to 
      follow the clues. The first destination was clear: the old lighthouse on 
      Beacon Point, where her great-grandfather had once worked.
      
      The lighthouse had been abandoned for decades, but something told her that the 
      answers she sought were waiting there. She packed a small bag with essentials 
      and set out on what would become the adventure of a lifetime.
      
      As she walked through the village, she noticed how quiet everything seemed. The 
      usual bustle of daily life felt muted, as if the world itself was holding its 
      breath. Even the seagulls seemed to call more softly than usual.
      
      **Little did she know** that others were also searching for the same treasure, 
      and they would stop at nothing to claim it for themselves.
    MD
    
    # Repeat the content multiple times to create a longer document
    base_text * 15
  end
  
  # Convert Sparx syntax to standard Markdown for fair comparison
  def self.sparx_to_markdown(text)
    # Convert basic formatting (this is just for benchmark fairness)
    converted = text.dup
    converted.gsub!(/\*\[([^\]]+)\]/, '**\1**')  # *[bold] -> **bold**  
    converted.gsub!(/\/\[([^\]]+)\]/, '*\1*')    # /[italic] -> *italic*
    converted.gsub!(/`([^`]+)`/, '`\1`')         # Code stays the same
    converted.gsub!(/>\[([^\]]+)\]/, '> \1')     # >[quote] -> > quote
    converted
  end
end

class BenchmarkRunner
  def initialize
    @results = {}
    setup_parsers
  end
  
  def setup_parsers
    @parsers = {}
    
    @parsers[:sparx] = ->(text) { Sparx.parse(text) }
    
    if REDCARPET_AVAILABLE
      renderer = Redcarpet::Render::HTML.new(filter_html: false, no_styles: false)
      markdown = Redcarpet::Markdown.new(renderer, 
        autolink: true, tables: true, fenced_code_blocks: true, 
        strikethrough: true, superscript: true)
      @parsers[:redcarpet] = ->(text) { markdown.render(text) }
    end
    
    if KRAMDOWN_AVAILABLE
      @parsers[:kramdown] = ->(text) { 
        Kramdown::Document.new(text, 
          input: 'kramdown',
          enable_coderay: false,
          syntax_highlighter: nil
        ).to_html 
      }
    end
    
    if COMMONMARKER_AVAILABLE
      @parsers[:commonmarker] = ->(text) { 
        begin
          # Try the newer API first
          if defined?(Commonmarker) && Commonmarker.respond_to?(:to_html)
            Commonmarker.to_html(text)
          elsif defined?(Commonmarker) && Commonmarker.respond_to?(:parse)
            doc = Commonmarker.parse(text)
            doc.to_html
          else
            # Fallback
            text
          end
        rescue => e
          puts "CommonMarker error: #{e.message}"
          text
        end
      }
    end
    
    puts "Available parsers: #{@parsers.keys.join(', ')}"
  end
  
  def run_benchmarks
    documents = {
      blog_post: BenchmarkDocuments.blog_post,
      technical_doc: BenchmarkDocuments.technical_doc, 
      novel_chapter: BenchmarkDocuments.novel_chapter
    }
    
    documents.each do |doc_name, content|
      puts "\\n" + "="*60
      puts "BENCHMARKING: #{doc_name.upcase} (#{content.length} chars)"
      puts "="*60
      
      # Convert Sparx syntax to standard Markdown for other parsers
      markdown_content = BenchmarkDocuments.sparx_to_markdown(content)
      
      run_memory_benchmark(doc_name, content, markdown_content)
      run_speed_benchmark(doc_name, content, markdown_content)
      run_ips_benchmark(doc_name, content, markdown_content)
    end
    
    print_summary
  end
  
  def run_memory_benchmark(doc_name, sparx_content, markdown_content)
    puts "\\nMemory Usage:"
    puts "-" * 30
    
    @parsers.each do |name, parser|
      content = (name == :sparx) ? sparx_content : markdown_content
      
      before = `ps -o rss= -p #{Process.pid}`.to_i
      parser.call(content)
      after = `ps -o rss= -p #{Process.pid}`.to_i
      
      memory_used = after - before
      puts sprintf("%-12s: %d KB", name, memory_used)
    end
  end
  
  def run_speed_benchmark(doc_name, sparx_content, markdown_content)
    puts "\\nExecution Time (5 runs each):"
    puts "-" * 40
    
    Benchmark.bm(12) do |x|
      @parsers.each do |name, parser|
        content = (name == :sparx) ? sparx_content : markdown_content
        x.report(name.to_s) do
          5.times { parser.call(content) }
        end
      end
    end
  end
  
  def run_ips_benchmark(doc_name, sparx_content, markdown_content)
    puts "\\nIterations Per Second:"
    puts "-" * 30
    
    Benchmark.ips do |x|
      @parsers.each do |name, parser|
        content = (name == :sparx) ? sparx_content : markdown_content
        x.report(name.to_s) { parser.call(content) }
      end
      x.compare!
    end
  end
  
  def print_summary
    puts "\\n" + "="*60
    puts "BENCHMARK SUMMARY"
    puts "="*60
    puts "Ruby Version: #{RUBY_VERSION}"
    puts "Available Parsers: #{@parsers.keys.join(', ')}"
    puts "\\nKey Takeaways:"
    puts "- Numbers above show relative performance across different document types"
    puts "- Memory usage measured as RSS delta (rough approximation)" 
    puts "- IPS (iterations per second) is most reliable metric"
    puts "- Sparx's unique features (citations, details tags) not included in comparison"
  end
end

# Run the benchmarks
if __FILE__ == $0
  puts "Sparx Performance Benchmark Suite"
  puts "====================================="
  puts "Testing against: Redcarpet, Kramdown, CommonMarker"
  puts "Document types: Blog Post, Technical Doc, Novel Chapter"
  
  runner = BenchmarkRunner.new
  runner.run_benchmarks
end