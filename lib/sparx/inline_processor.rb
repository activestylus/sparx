module Sparx
  SAFE_PROTOCOLS = %w[http https tel mailto sms facetime skype whatsapp geo zoom spotify vscode ftp].freeze
  ESCAPE_HTML = {'&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;', "'" => '&#39;'}.freeze
  ESCAPE_ATTR = {'"' => '&quot;', "'" => '&#39;', '<' => '&lt;', '>' => '&gt;'}.freeze
  STANDALONE = /([*\/-]+)\[([^\[\]]*)\]/.freeze
  HEADING = /^(\#{1,6})(?!\#)\s+(.+)$/.freeze
  LINK_FORMAT =/([*\/-]*)\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*?)\](\/[a-zA-Z0-9]|[a-zA-Z0-9]+:\/\/|www\.|@|#|(?:tel|mailto|sms|facetime|skype|whatsapp|geo|zoom|spotify|vscode):)([^\s\[\]^]*)(\^[a-zA-Z0-9_]*)?/.freeze
  BRACKETS1 = /([*\/-]+)\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*)\]/.freeze
  BRACKETS2 =  /([*\/-]+)\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*)\]/.freeze
  CITATIONS = /([*\/-]*)\[([^\[\]]+?)\]@([a-zA-Z0-9_-]+)/.freeze
  CITATION = /@([a-zA-Z0-9_-]+):\s*([^\s]+)(?:\s+"((?:[^"\\]|\\.)*)"\s*)?/.freeze
  CITATION_REMOVE = /@([a-zA-Z0-9_-]+):\s*([^\s]+)(?:\s+"((?:[^"\\]|\\.)*)")?/.freeze
  NUMBERED_CITE_REMOVE = /^(\d+)\[([^\]]+)\]\s*([^\s]+)(?:\s+"((?:[^"\\]|\\.)*)")?/.freeze
  NUMBERED_CITE = /^(\d+)\[([^\]]+)\]\s*([^\s]+)(?:\s+"((?:[^"\\]|\\.)*)")?/.freeze
  UNSAFE = /^(javascript|data|vbscript):/i.freeze
  CODE = /```(\w+)?\n?(.*?)```/m.freeze
  TABLES = /(^\|.*\|$\n?)+/m.freeze
  TABLE_ROWS = /^\|[-|]+\|$/.freeze
  PARAGRAPH_SPLIT = /\n(?:\s*\n)+/.freeze
  DOUBLE_NEWLINE = /\n\s*\n/.freeze
  FORMAT_PROTECT = /([*\/-]+\[[^\]]*\])/.freeze
  LINK_PROTECT = /(\[[^\]]*\]\(?[^\s\)]+\)?)/.freeze
  private
  def self.process_inline_code(content); content.gsub(/`([^`]+)`/) { "<code>#{$1}</code>" }; end
  def self.process_small_tags(content, recursive_processor = nil); content.gsub(/s\[(.*?)\]/m) { "<small>#{recursive_processor ? recursive_processor.call($1, {}, {}) : $1}</small>" }; end
  def self.process_span_classes(content, recursive_processor = nil); content.gsub(/\.([a-zA-Z0-9_-]+)\[(.*?)\]/m) { "<span class=\"#{$1}\">#{recursive_processor ? recursive_processor.call($2, {}, {}) : $2}</span>" }; end
def self.process_links_with_formatting(content, citations, numbered_citations, recursive_processor = nil)
  content.gsub(LINK_FORMAT) do
    prefix, inner, url_prefix, url_suffix, target = $1, $2, $3, $4, $5
    
    # Keep the URL validation logic exactly as you had it
    full_url = "#{url_prefix}#{url_suffix}"
    next apply_formatting_prefixes(recursive_processor ? recursive_processor.call(inner, citations, numbered_citations) : inner, prefix) unless valid_url?(url_prefix, url_suffix)
    
    # Optimize the inner processing
    text, title = inner.split('|', 2)
    escaped_text = escape_html_content(text || "")
    processed_content = recursive_processor ? recursive_processor.call(escaped_text, citations, numbered_citations) : escaped_text
    
    # Optimize attribute building
    link_attrs = %Q(href="#{full_url}")
    link_attrs += %Q( title="#{escape_html_attr(title)}") if title && !title.empty?
    if target
      target_value = target[1..-1].empty? ? '_blank' : target[1..-1]
      link_attrs += %Q( target="#{target_value}")
    end
    
    apply_formatting_prefixes(%Q(<a #{link_attrs}>#{processed_content}</a>), prefix)
  end
end
def self.valid_url?(url_prefix, url_suffix)
  return false if url_prefix == "/" && (url_suffix.empty? || url_suffix =~ /^[.,;!?]/)
  full_url = "#{url_prefix}#{url_suffix}"
  return false if full_url.length <= 1
  if full_url =~ /^([a-zA-Z]+):/i
    return SAFE_PROTOCOLS.include?($1.downcase)
  end
  
  true
end
  def self.process_standalone_formatting(content, recursive_processor = nil)
    content.gsub(STANDALONE) do
      prefix, inner = $1, $2;processed_content = recursive_processor ? recursive_processor.call(inner, {}, {}) : inner;apply_formatting_prefixes(processed_content, prefix)
    end
  end
def self.process_bracket_formatting_loops(text, citations, numbered_citations)
  while text =~ BRACKETS1
    text = text.gsub(BRACKETS2) {|match| prefix, inner = $1, $2
    processed_content = parse_styles(inner, citations, numbered_citations)
    apply_formatting_prefixes(processed_content, prefix)}
  end
  text
end
  def self.apply_formatting_prefixes(content, prefix);prefix.each_char.reverse_each {|p| content = case p;when '*';"<strong>#{content}</strong>";when '/';"<em>#{content}</em>";when '-';"<del>#{content}</del>";else;content;end};content;end
def self.escape_html_content(text)
  return text if text.nil?
  text.gsub(/[&<>"']/) { |char| ESCAPE_HTML[char] }
end
def self.escape_html_attr(str)
  return "" if str.nil? || str.empty?
  str.gsub(/["'<>]/) { |char| ESCAPE_ATTR[char] }
end
def self.process_citations(content, citations, numbered_citations, recursive_processor = nil)
  content.gsub(CITATIONS) do
    prefix, inner, cite_id = $1, $2, $3
    next "#{prefix}[#{inner}]@#{cite_id}" unless citations[cite_id]
    
    escaped_inner = escape_html_content(inner)
    processed_content = recursive_processor ? recursive_processor.call(escaped_inner, citations, numbered_citations) : escaped_inner
    url = citations[cite_id][:url]
    title_attr = citations[cite_id][:title] ? %Q( title="#{escape_html_attr(citations[cite_id][:title])}") : ""
    
    apply_formatting_prefixes(%Q(<a href="#{url}"#{title_attr}>#{processed_content}</a>), prefix)
  end
end
def self.process_numbered_citations(content, citations, numbered_citations, recursive_processor = nil)
  content.gsub(/([*\/-]*)\[([^\[\]]+?)\]:(\d+)/) do
    prefix, inner, cite_num = $1, $2, $3
    next "#{prefix}[#{inner}]:#{cite_num}" unless numbered_citations[cite_num]
    processed_content = recursive_processor ? recursive_processor.call(inner, citations, numbered_citations) : inner
    apply_formatting_prefixes(%Q(<a href="#cite-#{cite_num}">#{processed_content}<sup>#{cite_num}</sup></a>), prefix)
  end
end
    def self.process_all_inline_elements(content, citations, numbered_citations, recursive_processor = nil)
    content = process_images(content, citations, numbered_citations, recursive_processor)
    content = process_citations(content, citations, numbered_citations, recursive_processor)
    content = process_numbered_citations(content, citations, numbered_citations, recursive_processor)
    content = process_inline_code(content)
    content = process_small_tags(content, recursive_processor)
    content = process_span_classes(content, recursive_processor)
    content = process_links_with_formatting(content, citations, numbered_citations, recursive_processor)
    process_standalone_formatting(content, recursive_processor)
  end
def self.process_code_blocks(text)
  text.gsub(CODE) do
    lang, code = $1, $2.rstrip.gsub(/^\s{2}/, '')
    escaped_code = code.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    lang_class = lang ? %Q( class="language-#{lang}") : ""
    "<pre><code#{lang_class}>#{escaped_code}</code></pre>"
  end.gsub(/`([^`]+)`/) do
    escaped_content = $1.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    "<code>#{escaped_content}</code>"
  end
end
def self.process_headings(text, citations, numbered_citations)
  text.gsub(HEADING) do
    level, content = $1.length, $2
    "<h#{level}>#{process_all_inline_elements(content, citations, numbered_citations, method(:parse_styles_recursive))}</h#{level}>"
  end
end
def self.process_tables(text)
  text.gsub(TABLES) do |tbl|
    rows = tbl.strip.split("\n")
    header_cells = rows.shift.split("|").reject(&:empty?).map { |c| "<th>#{escape_html_content(c.strip)}</th>" }.join
    rows.shift if rows.first && rows.first.strip =~ TABLE_ROWS
    body = rows.map do |r|
      cells = r.split("|").reject(&:empty?).map { |c| "<td>#{escape_html_content(c.strip)}</td>" }.join
      "<tr>#{cells}</tr>"
    end.join
    "<table><thead><tr>#{header_cells}</tr></thead><tbody>#{body}</tbody></table>"
  end
end


def self.extract_citations(text)
  citations = {}
  text.scan(CITATION) do |id, url, title|
    next if url =~ UNSAFE
    citations[id] = { url: url, title: title }
  end
  citations
end


def self.extract_numbered_citations(text)
  numbered_citations = {}
  text.scan(NUMBERED_CITE) do |number, title, url, description|
    numbered_citations[number] = { 
      title: title.strip, 
      url: url.strip, 
      description: description ? description.strip : nil 
    }
  end
  numbered_citations
end


def self.remove_citation_definitions(text)
  text.gsub(CITATION_REMOVE, "").gsub(NUMBERED_CITE_REMOVE, "")
end
def self.add_numbered_citations_section(text, numbered_citations)
  return text if numbered_citations.empty?
  
  citation_html = numbered_citations.keys.sort_by(&:to_i).map do |num| 
    cite = numbered_citations[num]
    title_attr = cite[:description] ? %Q( title="#{escape_html_attr(cite[:description])}") : ""
    escaped_title = escape_html_content(cite[:title])
    %Q(<cite id="cite-#{num}"><span class="cite-number">#{num}</span> <a href="#{cite[:url]}"#{title_attr}>#{escaped_title}</a></cite>)
  end.join("\n")
  
  text + "\n\n<section class=\"citations\">\n#{citation_html}\n</section>"
end
def self.wrap_paragraphs_if_needed(text, original_text)
  return text unless original_text.match?(DOUBLE_NEWLINE)
  placeholder_names = (CONTAINER_SPECS.values.map { |s| s[:placeholder] } + LIST_SPECS.values.map { |s| s[:placeholder] }).uniq.join('|')
  block_element_regex = /\A(<(ul|ol|table|blockquote|pre|h\d|div|details|section|img|dl|aside|figure)|(#{placeholder_names}))/i
  text.split(PARAGRAPH_SPLIT).map { |block|
    block.strip!
    block.empty? ? nil : (block =~ block_element_regex ? block : "<p>#{block}</p>")
  }.compact.join("\n\n")
end


def self.escape_html_content_except_syntax(text)
  placeholders = {}
  
  text = text.gsub(FORMAT_PROTECT) { placeholders["F_#{placeholders.size}"] = $1; "%%%F_#{placeholders.size}%%%" }
  text = text.gsub(LINK_PROTECT) { placeholders["L_#{placeholders.size}"] = $1; "%%%L_#{placeholders.size}%%%" }
  text = escape_html_content(text)
  
  placeholders.each { |k, v| text.gsub!("%%%#{k}%%%", v) }
  text
end
end