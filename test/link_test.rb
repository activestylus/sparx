require_relative "test_helper"
class TestSparxLinks < Minitest::Test
  
  def test_link_with_title
    input = "[GitHub|Visit GitHub's homepage]https://github.com"
    output = Sparx.parse(input)
    assert_match /<a href="https:\/\/github\.com" title="Visit GitHub&#39;s homepage">GitHub<\/a>/, output
  end

  def test_link_with_target_blank
    input = "[GitHub]https://github.com^"
    output = Sparx.parse(input)
    assert_match /<a href="https:\/\/github\.com" target="_blank">GitHub<\/a>/, output
  end

  def test_link_with_custom_target
    input = "[GitHub]https://github.com^top"
    output = Sparx.parse(input)
    assert_match /<a href="https:\/\/github\.com" target="top">GitHub<\/a>/, output
  end

  def test_link_with_title_and_target
    input = "[GitHub|Visit GitHub]https://github.com^"
    output = Sparx.parse(input)
    assert_match /<a href="https:\/\/github\.com" title="Visit GitHub" target="_blank">GitHub<\/a>/, output
  end

  def test_link_with_formatting_in_text
    input = "[*[Bold] and /[italic] link|Tooltip]https://example.com^"
    output = Sparx.parse(input)
    expected = /<a href="https:\/\/example\.com" title="Tooltip" target="_blank"><strong>Bold<\/strong> and <em>italic<\/em> link<\/a>/
    assert_match expected, output
  end

  def test_link_with_formatted_prefix
    input = "*[Bold link|Tooltip]https://example.com"
    output = Sparx.parse(input)
    assert_match /<strong><a href="https:\/\/example\.com" title="Tooltip">Bold link<\/a><\/strong>/, output
  end

  def test_internal_section_link
    input = '[Go to intro]#intro-section'
    output = Sparx.parse(input)
    assert_match /<a href="#intro-section">Go to intro<\/a>/, output
  end

  # ============= EDGE CASES =============
  
  def test_image_empty_title
    input = "i[Mountain view]image.jpg"
    output = Sparx.parse(input)
    # Should not include empty title attribute
    assert_match /<img src="image\.jpg" alt="Mountain view">/, output
    refute_match /title=""/, output
  end

  def test_link_empty_title
    input = "[GitHub]https://github.com"
    output = Sparx.parse(input)
    # Should not include empty title attribute
    assert_match /<a href="https:\/\/github\.com">GitHub<\/a>/, output
    refute_match /title=""/, output
  end

  def test_url_with_equals_not_dimensions
    input = "[Search]https://example.com?query=test&size=large"
    output = Sparx.parse(input)
    assert_match /<a href="https:\/\/example\.com\?query=test&size=large">Search<\/a>/, output
  end

  def test_image_url_prefix_not_found
    input = "i[Mountain]@missing/image.jpg"
    output = Sparx.parse(input)
    # Should handle gracefully when URL prefix not defined
    assert_match /<img src="image\.jpg" alt="Mountain">/, output
  end

  def test_empty_section
    input = '$[empty]{}'
    output = Sparx.parse(input)
    assert_match /<section id="empty"><\/section>/, output
  end

  def test_section_id_validation
    input = '$[valid-name_123]{Content}'
    output = Sparx.parse(input)
    assert_match /<section id="valid-name_123">/, output
  end
end