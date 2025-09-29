module Sparx
  def self.process_all_containers(text, citations, numbered_citations)
    original_text = text.dup
    all_caches = {}
    text = process_responsive_images(text, citations, numbered_citations)
    CONTAINER_SPECS.each do |type, spec|
      result = process_container_type(text, spec, citations, numbered_citations, type)
      text = result[:text]
      all_caches[type] = result[:cache]
    end
    LIST_SPECS.each do |type, spec|
      result = process_list_type(text, spec, citations, numbered_citations, type)
      text = result[:text]
      all_caches[type] = result[:cache]
    end
    text = parse_styles(text, citations, numbered_citations)
    text = wrap_paragraphs_if_needed(text, original_text)
    max_iterations = 10
    iteration = 0
    while iteration < max_iterations
      replacements_made = false
      (LIST_SPECS.keys + CONTAINER_SPECS.keys).reverse.each do |type|
        all_caches[type]&.each do |placeholder, html|
          if text.include?(placeholder)
            text = text.gsub(placeholder, html)
            replacements_made = true
        end
      end
    end
      break unless replacements_made
      iteration += 1
    end
    text
  end
  def self.process_container_type(text, spec, citations, numbered_citations, type)
    container_cache = {}
    @global_counters[spec[:placeholder]] ||= 0
    while match = text.match(spec[:pattern])
      start_pos = match.begin(0)
      content_start = match.end(0)
    end_pos = find_matching_brace(text, content_start)
      content = text[content_start...end_pos].strip
      params = spec[:extract_params].call(match)
      processed_content = process_all_containers(content, citations, numbered_citations)
      html = spec[:build_html].call(params, processed_content, citations, numbered_citations)
      placeholder = "#{spec[:placeholder]}#{@global_counters[spec[:placeholder]]}END"
      @global_counters[spec[:placeholder]] += 1
      container_cache[placeholder] = html
      text = text[0...start_pos] + placeholder + text[end_pos + 1..-1]
    end
    { text: text, cache: container_cache }
  end
  def self.process_list_type(text, spec, citations, numbered_citations, type)
  cache = {}
  @global_counters[spec[:placeholder]] ||= 0
  lines = text.split("\n")
  result_lines = []
  i = 0
  complex_just_closed = false
  while i < lines.length
    line = lines[i]
    simple_match = line.match(spec[:simple_pattern])
    complex_match = line.match(spec[:complex_pattern])
    if simple_match || complex_match
      items = []
      while i < lines.length
        current_line = lines[i]
        if type == :dl
          if !current_line.strip.empty? && !current_line.match(spec[:simple_pattern]) && !current_line.match(spec[:complex_pattern])
            break
         end
          if current_line.strip.empty?
            if i + 1 < lines.length
              next_line = lines[i + 1]
              if next_line.match(spec[:simple_pattern]) || next_line.match(spec[:complex_pattern])
                i += 1
                next
              else
                break
             end
            else
              break
           end
         end
       end
        if match = current_line.match(spec[:complex_pattern])
          i += 1
          content_lines = []
          brace_count = 1
          while i < lines.length && brace_count > 0
            content_line = lines[i]
            content_line.each_char do |char|
              brace_count += 1 if char == '{'
              brace_count -= 1 if char == '}'
           end
            if brace_count > 0
              content_lines << content_line
            else
              close_pos = content_line.rindex('}')
              content_lines << content_line[0...close_pos] if close_pos && close_pos > 0
           end
            i += 1
         end
          content = content_lines.join("\n").strip
          original_content = content.dup
          processed_content = process_all_containers(content, citations, numbered_citations)
          if original_content.match?(/\n\s*\n/)
            processed_content = processed_content
          else
            unless processed_content.match(/\A<(ul|ol|table|blockquote|pre|h\d|div|details|section|img|dl|aside|figure)/)
              processed_content = "<p>#{processed_content}</p>"
           end
         end
          params = spec[:extract_item_params].call(match, processed_content)
          original_level = params[:level]
          if type == :dl && complex_just_closed
            params[:level] = 1
            if original_level == 1
              complex_just_closed = false
           end
         end
          params[:closed] = true
          if type == :dl
            params[:term] = process_all_inline_elements(params[:term], citations, numbered_citations)
         end
          items << params
          complex_just_closed = true
        elsif match = current_line.match(spec[:simple_pattern])
          params = spec[:extract_item_params].call(match)
          original_level = params[:level]
          if type == :dl && complex_just_closed
            params[:level] = 1
            if original_level == 1
              complex_just_closed = false
           end
         end
          if type == :dl
            params[:term] = process_all_inline_elements(params[:term], citations, numbered_citations)
            params[:description] = process_all_inline_elements(params[:description], citations, numbered_citations)
          else
            params[:content] = process_all_inline_elements(params[:content], citations, numbered_citations)
         end
          items << params
          i += 1
        else
          break
       end
     end
      if items.any?
        html = spec[:build_html].call(items)
        placeholder = "#{spec[:placeholder]}#{@global_counters[spec[:placeholder]]}END"
        @global_counters[spec[:placeholder]] += 1
        cache[placeholder] = html
        result_lines << placeholder
        i -= 1
      else
        result_lines << line
     end
    else
      result_lines << line
    end
    i += 1
  end
  { text: result_lines.join("\n"), cache: cache }
  end
  def self.find_matching_brace(text, start_pos)
    brace_count = 1
    pos = start_pos
    while pos < text.length && brace_count > 0
      if text[pos] == '{'
        brace_count += 1
      elsif text[pos] == '}'
        brace_count -= 1
    end
      pos += 1
    end
    pos - 1
  end
  def self.build_nested_list(items, list_type);return "" if items.empty?;html, _ = build_list_recursive(items, 0, list_type, 1);html;end
  def self.build_list_recursive(items, start_index, list_type, expected_level)
    return ["", start_index] if start_index >= items.length
    html = "<#{list_type}>"
    i = start_index
    while i < items.length
      item = items[i]
      if item[:level] == expected_level
        html += "<li>#{item[:content]}"
        if i + 1 < items.length && items[i + 1][:level] > expected_level
          nested_html, new_i = build_list_recursive(items, i + 1, list_type, expected_level + 1)
          html += nested_html
          i = new_i - 1
      end
        html += "</li>";i += 1;elsif item[:level] < expected_level;break;else;i += 1;end
    end
    html += "</#{list_type}>";[html, i]
  end
  def self.build_nested_definition_list(items);return "" if items.empty?;html, _ = build_definition_list_recursive(items, 0, 1);html;end
  def self.build_definition_list_recursive(items, start_index, expected_level)
    return ["", start_index] if start_index >= items.length
    html = "<dl>";i = start_index
    while i < items.length
      item = items[i]
      if item[:level] == expected_level
        html += "<dt>#{item[:term]}</dt>"
        html += "<dd>#{item[:description]}"
        if !item[:closed] && i + 1 < items.length && items[i + 1][:level] > expected_level
          nested_html, new_i = build_definition_list_recursive(items, i + 1, expected_level + 1)
          html += nested_html
          i = new_i - 1
        end
        html += "</dd>"
        i += 1
      elsif item[:level] < expected_level;break;else;i += 1;end
    end
    html += "</dl>";[html, i]
  end
end