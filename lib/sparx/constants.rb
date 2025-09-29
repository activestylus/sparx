module Sparx
  MIME_TYPES = {'webp' => 'image/webp','avif' => 'image/avif','jpg' => 'image/jpeg','jpeg' => 'image/jpeg','png' => 'image/png','gif' => 'image/gif','svg' => 'image/svg+xml'}.freeze
  CONTAINER_SPECS = {
     details: {
        pattern: /\+\[(.*?)\]\{/, placeholder: "DETAILSPLACEHOLDER",
        build_html: ->(matches, content, citations, numbered_citations) {
           summary = process_all_inline_elements(matches[:summary], citations, numbered_citations)
           "<details><summary>#{summary}</summary>#{content}</details>"
        },extract_params: ->(match) { {summary: match[1]} }
     },
      section: {
        pattern: /\$\[([^\]]+)\]\{/,  # Change this to accept any characters in []
        placeholder: "SECTIONPLACEHOLDER",
        build_html: ->(matches, content, citations, numbered_citations) {  
          id = escape_html_attr(matches[:id])  # Escape the ID
          "<section id=\"#{id}\">#{content}</section>"  
        },
        extract_params: ->(match) { {id: match[1]} }
      },
     blockquote: {
        pattern: />(?:\[([^\]]+)\])?\{/, placeholder: "BLOCKQUOTEPLACEHOLDER",
        build_html: ->(matches, content, citations, numbered_citations) {  
           cite_attr = matches[:cite] ? " cite=\"#{escape_html_attr(matches[:cite])}\"" : ""
           "<blockquote#{cite_attr}>#{content}</blockquote>"  
        },extract_params: ->(match) { {cite: match[1]} }
     },
     div_class: {
        pattern: /\.([a-zA-Z0-9_-]+)\{/, placeholder: "DIVPLACEHOLDER",
        build_html: ->(matches, content, citations, numbered_citations) {  
           "<div class=\"#{matches[:class_name]}\">#{content}</div>"  
        },extract_params: ->(match) { {class_name: match[1]} }
     },
     aside: {
        pattern: /~\{/, placeholder: "ASIDEPLACEHOLDER",  
        build_html: ->(matches, content, citations, numbered_citations) {  
           "<aside>#{content}</aside>"  
        },extract_params: ->(match) { {} }
     },
     figure: {
        pattern: /f\[(.*?)\]\{/, placeholder: "FIGUREPLACEHOLDER",
        build_html: ->(matches, content, citations, numbered_citations) {
           caption = process_all_inline_elements(matches[:caption], citations, numbered_citations)
           "<figure>#{content}<figcaption>#{caption}</figcaption></figure>"
        },extract_params: ->(match) { {caption: match[1]} }
     }
  }.freeze
  LIST_SPECS = {
     ul: {
        simple_pattern: /^\s*(-+)\s+(.+)$/,complex_pattern: /^\s*(-+)\{$/, placeholder: "ULPLACEHOLDER",
        build_html: ->(items) {build_nested_list(items, 'ul')},
        extract_item_params: ->(match, content = nil) {{level: match[1].length, content: content || match[2]}}
     },
     ol: {
        simple_pattern: /^\s*(\++)\s+(.+)$/,complex_pattern: /^\s*(\++)\{$/, placeholder: "OLPLACEHOLDER",
        build_html: ->(items) {build_nested_list(items, 'ol')},
        extract_item_params: ->(match, content = nil) {{level: match[1].length, content: content || match[2]}}
     },
     dl: {
        simple_pattern: /^\s*(:+)([^:]+):\s*(.*)$/,complex_pattern: /^\s*(:+)([^:]+):\{$/, placeholder: "DLPLACEHOLDER",
        build_html: ->(items) {build_nested_definition_list(items)},
        extract_item_params: ->(match, content = nil) {
           {level: match[1].length, term: match[2].strip, description: (content ? content : match[3].strip)}
        }
     }
  }.freeze


  def self.global_counters
    @global_counters ||= {}
  end
end