module Sparx
def self.parse(text, safe: false)
  text = text.gsub("\x00", "")
  
  if safe
    # Process code blocks FIRST to protect them from safe mode escaping
    code_blocks = {}
    counter = 0
    
    # Extract and protect code blocks
    text = text.gsub(/```(\w+)?\n?(.*?)```/m) do
      lang = $1
      code = $2
      placeholder = "%%%CODEBLOCK_#{counter}%%%"
      code_blocks[placeholder] = { lang: lang, code: code }
      counter += 1
      placeholder
    end
    
    # Extract and protect inline code
    text = text.gsub(/`([^`]+)`/) do
      placeholder = "%%%INLINECODE_#{counter}%%%"
      code_blocks[placeholder] = { inline: true, code: $1 }
      counter += 1
      placeholder
    end
    
    # NOW escape HTML in remaining content
    text = text.gsub(/<[^>]+>/) { |tag| escape_html_content(tag) }
    
    # Restore code blocks (they'll be processed normally later)
    code_blocks.each do |placeholder, data|
      if data[:inline]
        text.gsub!(placeholder, "`#{data[:code]}`")
      else
        lang = data[:lang] ? "#{data[:lang]}\n" : ""
        text.gsub!(placeholder, "```#{lang}#{data[:code]}```")
      end
    end
  end
  
  global_counters.clear
  original_text = text.dup
  citations = extract_citations(text)
  numbered_citations = extract_numbered_citations(text)
  text = remove_citation_definitions(text)
  parsed_text = process_all_containers(text, citations, numbered_citations)
  parsed_text = add_numbered_citations_section(parsed_text, numbered_citations)
  parsed_text
end
  private
def self.parse_styles(text, citations, numbered_citations)
  return "" if text.nil?
  text = process_code_blocks(text)
  text = process_headings(text, citations, numbered_citations) 
  text = process_tables(text)
  # KEEP this but FIX the recursion:
  text = process_all_inline_elements(text, citations, numbered_citations, nil)
  process_bracket_formatting_loops(text, citations, numbered_citations)
end
  def self.parse_styles_recursive(content, citations, numbered_citations)
    parse_styles(content, citations, numbered_citations)
  end
end