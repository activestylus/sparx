require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/sparx'

# class Testsparx < Minitest::Test
# def test_method_availability
#   puts "Available methods: #{sparx.methods.grep(/process|parse/).sort}"
#   assert sparx.respond_to?(:process_links_with_formatting)
#   assert sparx.respond_to?(:escape_html_attr)
#   assert sparx.respond_to?(:process_images)
# end
# end