module Sparx
  def self.process_srcset_with_expansion(srcset_parts, media_attr, url_prefix, citations)
    expanded_items = []
    srcset_parts.each do |part|
      if part.match(/^(.+\{[^}]+\})(.*)$/)
        path_with_braces, suffix = $1, $2.strip
        width_descriptor = suffix.match(/^(\d+w)/) ? $1 : nil
        if path_with_braces.match(/^(.+)\{([^}]+)\}$/)
          base_path, extensions = $1, $2.split(',').map(&:strip)
          extensions.each do |ext|
            expanded_items << {path: "#{base_path}#{ext}", width: width_descriptor, ext: ext}
          end
        end
      elsif match = part.match(/^([^\s]+)\s*(\d+w)?$/)
        path, width, ext = match[1], match[2], File.extname(match[1]).sub('.', '')
        expanded_items << {path: path, width: width, ext: ext}
      end
    end
    grouped = expanded_items.group_by { |item| item[:ext] }
    sources = []
    grouped.each do |ext, items|
      srcset_value = items.map { |item|
        full_src = resolve_image_src(item[:path], url_prefix, citations)
        item[:width] ? "#{full_src} #{item[:width]}" : full_src
      }.join(', ')
      sources << build_source_tag(srcset_value, infer_type(ext), media_attr)
    end
    sources
  end
  def self.expand_source(path_str, media_attr, url_prefix, citations)
    sources = []
    if path_str.match(/^(.+)\{([^}]+)\}(.*)$/)
      base_path, extensions, suffix = $1, $2.split(',').map(&:strip), $3
      extensions.each do |ext|
        full_path = "#{base_path}#{ext}#{suffix}"
        actual_path = full_path.split(/\s+/).first
        width_descriptor = full_path.match(/\s+(\d+w)/) ? $1 : nil
        full_src = resolve_image_src(actual_path, url_prefix, citations)
        srcset_value = width_descriptor ? "#{full_src} #{width_descriptor}" : full_src
        sources << build_source_tag(srcset_value, infer_type(ext), media_attr)
      end
    else
      actual_path = path_str.split(/\s+/).first
      width_descriptor = path_str.match(/\s+(\d+w)/) ? $1 : nil
      full_src = resolve_image_src(actual_path, url_prefix, citations)
      ext = File.extname(actual_path).sub('.', '')
      srcset_value = width_descriptor ? "#{full_src} #{width_descriptor}" : full_src
      sources << build_source_tag(srcset_value, infer_type(ext), media_attr)
    end
    sources
  end
  def self.process_responsive_images(text, citations, numbered_citations)
    lines = text.split("\n")
    result_lines = []
    i = 0
    @global_counters['PICTUREPLACEHOLDER'] ||= 0
    picture_cache = {}
    while i < lines.length
      line = lines[i]
      if line.match(/^\s*src\[([^\]]+)\](.+)$/)
        src_elements = []
        start_i = i
        while i < lines.length && lines[i].match(/^\s*src\[([^\]]+)\](.+)$/)
          src_elements << lines[i]
          i += 1
          break if i >= lines.length
          next_line = lines[i]
          if next_line.strip.empty?
            if i + 1 < lines.length
              following = lines[i + 1]
              break unless following.match(/^\s*src\[/) || following.match(/^\s*([*\/-]*)i\[/)
            else
              break
            end
          elsif !next_line.match(/^\s*src\[/) && !next_line.match(/^\s*([*\/-]*)i\[/)
            break
          end
        end
        img_line_index = i
        img_line_index = i + 1 if i < lines.length && lines[i].strip.empty?
        if img_line_index < lines.length && lines[img_line_index].match(/^\s*([*\/-]*)i\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*?)\](@[a-zA-Z0-9_-]+)?([^\s\[\]=^]+)(?:=(\d+x\d+))?/)
          img_match = lines[img_line_index].match(/^\s*([*\/-]*)i\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*?)\](@[a-zA-Z0-9_-]+)?([^\s\[\]=^]+)(?:=(\d+x\d+))?/)
          prefix, inner, url_prefix, src, dimensions = img_match[1], img_match[2], img_match[3], img_match[4], img_match[5]
          sources = []
          src_elements.each do |src_line|
            src_match = src_line.match(/^\s*src\[([^\]]+)\](.+)$/)
            condition, path_and_srcset = src_match[1], src_match[2].strip
            local_url_prefix = url_prefix
            if path_and_srcset.match(/^(@[a-zA-Z0-9_-]+)(.+)$/)
              local_url_prefix = $1
              path_and_srcset = $2
            end
            media_attr = parse_media_condition(condition)
            if path_and_srcset.include?('|')
              sources.concat(process_srcset_with_expansion(path_and_srcset.split('|').map(&:strip), media_attr, local_url_prefix, citations))
            else
              sources.concat(expand_source(path_and_srcset, media_attr, local_url_prefix, citations))
            end
          end
          parts = inner.split('|', 2)
          alt, title = parts[0] || "", parts[1]
          full_src = resolve_image_src(src, url_prefix, citations)
          img_attrs = "src=\"#{full_src}\" alt=\"#{escape_html_attr(alt)}\""
          img_attrs += " title=\"#{escape_html_attr(title)}\"" if title && !title.empty?
          img_attrs += " width=\"#{dimensions.split('x')[0]}\" height=\"#{dimensions.split('x')[1]}\"" if dimensions
          picture_html = "<picture>\n#{sources.map { |s| "  #{s}" }.join("\n")}\n  <img #{img_attrs}>\n</picture>"
          picture_html = apply_formatting_prefixes(picture_html, prefix)
          placeholder = "PICTUREPLACEHOLDER#{@global_counters['PICTUREPLACEHOLDER']}END"
          @global_counters['PICTUREPLACEHOLDER'] += 1
          picture_cache[placeholder] = picture_html
          result_lines << placeholder
          i = img_line_index + 1
        else
          result_lines.concat(src_elements)
          i = start_i + src_elements.length
        end
      else
        result_lines << line
        i += 1
      end
    end
    text = result_lines.join("\n")
    picture_cache.each { |placeholder, html| text = text.gsub(placeholder, html) }
    text
  end
  def self.parse_media_condition(condition)
    return "(min-width: #{$1}px)" if condition.match(/^>(\d+)px$/)
    return "(max-width: #{$1}px)" if condition.match(/^<(\d+)px$/)
    nil
  end


  def self.infer_type(extension)
    MIME_TYPES[extension.downcase]
  end
  def self.build_source_tag(srcset, type_attr, media_attr)
    attrs = ["srcset=\"#{srcset}\""]
    attrs << "type=\"#{type_attr}\"" if type_attr
    attrs << "media=\"#{media_attr}\"" if media_attr
    "<source #{attrs.join(' ')}>"
  end
def self.process_images(content, citations, numbered_citations, recursive_processor = nil)
  content.gsub(/([*\/-]*)i\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*?)\](@[a-zA-Z0-9_-]+)?([^\n]+)/) do
    prefix = $1
    inner = $2
    url_prefix = $3
    remainder = $4.strip
    
    # Extract dimensions if present
    dimensions = nil
    if remainder =~ /(.+)=(\d+x\d+)$/
      remainder = $1.strip
      dimensions = $2
    end
    
    # CHECK FOR JAVASCRIPT PROTOCOL IN IMAGE SRC
    if remainder =~ /^javascript:/i
      # Block javascript: protocol in images
      next apply_formatting_prefixes("[IMAGE BLOCKED - UNSAFE PROTOCOL]", prefix)
    end
    
    if remainder.include?('|')
      srcset_items = remainder.split('|').map(&:strip)
      first_src = srcset_items[0].gsub(/\s+\d+w$/, '') 
      src_value = resolve_image_src(first_src, url_prefix, citations)
      srcset_value = srcset_items.map { |item|
        if item.match(/^([^\s]+)(?:\s+(\d+w))?$/)
          path = $1
          descriptor = $2
          full_path = resolve_image_src(path, url_prefix, citations)
          descriptor ? "#{full_path} #{descriptor}" : full_path
        end
      }.compact.join(', ')
      
      # ESCAPE THE IMAGE ATTRIBUTES (security fix)
      parts = inner.split('|', 2)
      alt = escape_html_content(parts[0] || "")
      title = parts[1] ? escape_html_content(parts[1]) : nil
      
      img_attrs = %Q(src="#{src_value}" srcset="#{srcset_value}" alt="#{alt}")
      img_attrs += %Q( title="#{title}") if title
      img_attrs += %Q( width="#{dimensions.split('x')[0]}" height="#{dimensions.split('x')[1]}") if dimensions
      apply_formatting_prefixes("<img #{img_attrs}>", prefix)
    else
      src = remainder
      
      # ESCAPE THE IMAGE ATTRIBUTES (security fix)
      parts = inner.split('|', 2)
      alt = escape_html_content(parts[0] || "")
      title = parts[1] ? escape_html_content(parts[1]) : nil
      
      full_src = resolve_image_src(src, url_prefix, citations)
      img_attrs = %Q(src="#{full_src}" alt="#{alt}")
      img_attrs += %Q( title="#{title}") if title
      img_attrs += %Q( width="#{dimensions.split('x')[0]}" height="#{dimensions.split('x')[1]}") if dimensions
      apply_formatting_prefixes("<img #{img_attrs}>", prefix)
    end
  end
end
  def self.resolve_image_src(src, url_prefix, citations)
    # Block dangerous protocols in images
    if src =~ /^(javascript|data|vbscript):/i
      return "[BLOCKED]"
    end
    
    return src.start_with?('/') ? src[1..-1] : src unless url_prefix
    prefix_id = url_prefix[1..-1]
    return src.start_with?('/') ? src[1..-1] : src unless citations[prefix_id] && citations[prefix_id][:url]
    
    base_url = citations[prefix_id][:url]
    
    # Block dangerous protocols in citation URLs too
    if base_url =~ /^(javascript|data|vbscript):/i
      return "[BLOCKED]"
    end
    if base_url.end_with?('/') && src.start_with?('/')
      base_url + src[1..-1]
    elsif !base_url.end_with?('/') && !src.start_with?('/')
        base_url + '/' + src
    else
        base_url + src
    end
  end
  def self.process_images(content, citations, numbered_citations, recursive_processor = nil)
    content.gsub(/([*\/-]*)i\[([^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*?)\](@[a-zA-Z0-9_-]+)?([^\n]+)/) do
      prefix = $1
      inner = $2
      url_prefix = $3
      remainder = $4.strip
      dimensions = nil
      if remainder =~ /(.+)=(\d+x\d+)$/
        remainder = $1.strip
        dimensions = $2
      end
      if remainder.include?('|')
        srcset_items = remainder.split('|').map(&:strip)
        first_src = srcset_items[0].gsub(/\s+\d+w$/, '') 
        src_value = resolve_image_src(first_src, url_prefix, citations)
        srcset_value = srcset_items.map { |item|
          if item.match(/^([^\s]+)(?:\s+(\d+w))?$/)
            path = $1
            descriptor = $2
            full_path = resolve_image_src(path, url_prefix, citations)
            descriptor ? "#{full_path} #{descriptor}" : full_path
          end
        }.compact.join(', ')
        parts = inner.split('|', 2)
        alt = parts[0] || ""
        title = parts[1]
        img_attrs = %Q(src="#{src_value}" srcset="#{srcset_value}" alt="#{escape_html_attr(alt)}")
        img_attrs += %Q( title="#{escape_html_attr(title)}") if title && !title.empty?
        img_attrs += %Q( width="#{dimensions.split('x')[0]}" height="#{dimensions.split('x')[1]}") if dimensions
        apply_formatting_prefixes("<img #{img_attrs}>", prefix)
      else
        src = remainder
        parts = inner.split('|', 2)
        alt = parts[0] || ""
        title = parts[1]
        full_src = resolve_image_src(src, url_prefix, citations)
        img_attrs = %Q(src="#{full_src}" alt="#{escape_html_attr(alt)}")
        img_attrs += %Q( title="#{escape_html_attr(title)}") if title && !title.empty?
        img_attrs += %Q( width="#{dimensions.split('x')[0]}" height="#{dimensions.split('x')[1]}") if dimensions
        apply_formatting_prefixes("<img #{img_attrs}>", prefix)
      end
    end
  end
end