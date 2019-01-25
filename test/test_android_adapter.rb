# frozen_string_literal: true

require 'minitest/autorun'
require 'fastlane/plugin/loco'
require_relative 'shared'

# Android Adapter Test class
class AndroidAdapterTest < Minitest::Test
  def test_parse
    xml = File.read('test/res/en.xml')

    adapter = ::Loco::AndroidAdapter.new

    strings, plurals = adapter.parse xml, '.xml'

    _check_parsed strings, plurals
  end

  def test_read_write
    adapter = ::Loco::AndroidAdapter.new

    strings, plurals = adapter.read 'test/res/*'

    _check_parsed strings, plurals

    written = adapter.to_xml strings, plurals

    assert_equal 27,
                 written.scan(/(?=<string name=)/).count,
                 'Not the right amount of written strings'

    assert_equal 8,
                 written.scan(/(?=<plurals name=)/).count,
                 'Not the right amount of written plurals'

    assert_equal 1,
                 written.scan(%r{(?=<item quantity="one">%d Adult</item>)}).count,
                 'Missing strings'

    assert_equal 1,
                 written.scan(/(?=<plurals name="adults">)/).count,
                 'Missing plurals'

    written_strings, written_plurals = adapter.parse written, '.xml'

    UI.user_error!('Sanity check failed') if (written_strings != strings) || (written_plurals != plurals)
  end
end
