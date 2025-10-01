require_relative "test_helper"
class TestBasicSparx < Minitest::Test
  # ============= BASIC FORMATTING TESTS =============
  def test_basic_formatting
    input = "*[bold]."
    output = Sparx.parse(input)
    assert_match /<strong>bold<\/strong>/, output
  end

  def test_italic_formatting
    input = "/[italic]"
    output = Sparx.parse(input)
    assert_match /<em>italic<\/em>/, output
  end

  def test_bold_italic_combination
    input = "/*[italic bold]"
    output = Sparx.parse(input)
    assert_match /<em><strong>italic bold<\/strong><\/em>/, output
  end

  def test_italic_bold_combination
    input = "*/[bold italic]"
    output = Sparx.parse(input)
    assert_match /<strong><em>bold italic<\/em><\/strong>/, output
  end

  def test_strikethrough
    input = "-[strikethrough text]"
    output = Sparx.parse(input)
    assert_match /<del>strikethrough text<\/del>/, output
  end

  def test_nested_formatting
    input = "/[italic with *[bold text]]"
    output = Sparx.parse(input)
    assert_match /<em>italic with <strong>bold text<\/strong><\/em>/, output
  end

  def test_bold_link
    input = "*[bold link]https://example.com"
    output = Sparx.parse(input)
    assert_match %r{<strong><a href="https://example.com">bold link</a></strong>}, output
  end

  def test_home_link
    input = "[home]/"
    output = Sparx.parse(input)
    assert_match %r{<a href="/">home</a>}, output
  end

  def test_bold_home_link
    input = "*[home]/"
    output = Sparx.parse(input)
    assert_match %r{<strong><a href="/">home</a></strong>}, output
  end

  def test_bold_italic_link
    input = "*/[bold italic link]https://example.org"
    output = Sparx.parse(input)
    assert_match %r{<strong><em><a href="https://example.org">bold italic link</a></em></strong>}, output
  end

  def test_italic_bold_link
    input = "/*[italic bold link]https://example.org"
    output = Sparx.parse(input)
    assert_match %r{<em><strong><a href="https://example.org">italic bold link</a></strong></em>}, output
  end

  def test_nested_formatting_in_links
    input = "/[italic link with *[bold text]]https://example.com"
    output = Sparx.parse(input)
    assert_match %r{<em><a href="https://example.com">italic link with <strong>bold text</strong></a></em>}, output
  end
	# ============= PROTOCOL LINK TESTS =============

	def test_tel_link
	  input = "[Call us]tel:12126195446"
	  output = Sparx.parse(input)
	  assert_match /<a href="tel:12126195446">Call us<\/a>/, output
	end

	def test_tel_link_with_formatting
	  input = "[212.619.5446]tel:+1-212-619-5446"
	  output = Sparx.parse(input)
	  assert_match /<a href="tel:\+1-212-619-5446">212\.619\.5446<\/a>/, output
	end

	def test_mailto_link
	  input = "[Email me]mailto:person@example.com"
	  output = Sparx.parse(input)
	  assert_match /<a href="mailto:person@example\.com">Email me<\/a>/, output
	end

	def test_mailto_with_subject
	  input = "[Contact]mailto:support@example.com?subject=Help"
	  output = Sparx.parse(input)
	  assert_match /<a href="mailto:support@example\.com\?subject=Help">Contact<\/a>/, output
	end

	def test_sms_link
	  input = "[Text us]sms:+12126195446"
	  output = Sparx.parse(input)
	  assert_match /<a href="sms:\+12126195446">Text us<\/a>/, output
	end

	def test_facetime_link
	  input = "[FaceTime]facetime:user@example.com"
	  output = Sparx.parse(input)
	  assert_match /<a href="facetime:user@example\.com">FaceTime<\/a>/, output
	end

	def test_skype_link
	  input = "[Call on Skype]skype:username?call"
	  output = Sparx.parse(input)
	  assert_match /<a href="skype:username\?call">Call on Skype<\/a>/, output
	end

	def test_whatsapp_link
	  input = "[WhatsApp]whatsapp:send?phone=12126195446"
	  output = Sparx.parse(input)
	  assert_match /<a href="whatsapp:send\?phone=12126195446">WhatsApp<\/a>/, output
	end

	def test_geo_link
	  input = "[View location]geo:37.786971,-122.399677"
	  output = Sparx.parse(input)
	  assert_match /<a href="geo:37\.786971,-122\.399677">View location<\/a>/, output
	end

	def test_zoom_link
	  input = "[Join meeting]zoom:joinconfid=123456789"
	  output = Sparx.parse(input)
	  assert_match /<a href="zoom:joinconfid=123456789">Join meeting<\/a>/, output
	end

	def test_spotify_link
	  input = "[Listen]spotify:track:abc123def456"
	  output = Sparx.parse(input)
	  assert_match /<a href="spotify:track:abc123def456">Listen<\/a>/, output
	end

	def test_vscode_link
	  input = "[Open file]vscode://file/path/to/file.rb"
	  output = Sparx.parse(input)
	  assert_match /<a href="vscode:\/\/file\/path\/to\/file\.rb">Open file<\/a>/, output
	end

	def test_protocol_links_with_formatting
	  input = "*[Bold call link]tel:12126195446"
	  output = Sparx.parse(input)
	  assert_match /<strong><a href="tel:12126195446">Bold call link<\/a><\/strong>/, output
	end

	def test_protocol_links_with_target
	  input = "[Email]mailto:test@example.com^"
	  output = Sparx.parse(input)
	  assert_match /<a href="mailto:test@example\.com" target="_blank">Email<\/a>/, output
	end

	def test_protocol_links_with_title
	  input = "[Contact|Send us a message]mailto:hello@example.com"
	  output = Sparx.parse(input)
	  assert_match /<a href="mailto:hello@example\.com" title="Send us a message">Contact<\/a>/, output
	end

	def test_javascript_protocol_not_supported
	  input = "[Click]javascript:alert('xss')"
	  output = Sparx.parse(input)
	  # Should not create a link - javascript protocol is not in allowlist
	  refute_match /<a href="javascript:/, output
	end
end