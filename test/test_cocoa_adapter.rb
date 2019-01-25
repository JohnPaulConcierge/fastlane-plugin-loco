# frozen_string_literal: true

require 'minitest/autorun'
require 'fastlane/plugin/loco'
require_relative 'shared'

# Cocoa Adapter Test class
class CocoaAdapterTest < Minitest::Test
  def test_read_write
    adapter = Loco::CocoaAdapter.new

    strings, plurals = adapter.read 'test/res/en.lproj/*'

    _check_parsed strings, plurals

    written_s = adapter.to_strings strings
    written_p = adapter.to_stringsdict plurals

    assert_equal 27,
                 written_s.scan(/(?=" = ")/).count,
                 'Not the right amount of written strings'

    assert_equal 8,
                 written_p.scan(%r{(?=<key>NSStringLocalizedFormatKey</key>)}).count,
                 'Not the right amount of written plurals'

    written_strings = adapter.read_strings written_s
    written_plurals = adapter.read_stringsdict written_p

    _check_parsed written_strings, written_plurals

    assert_equal written_strings,
                 strings,
                 'Sanity check failed with strings'

    assert_equal written_plurals,
                 plurals,
                 'Sanity check failed with plurals'
  end
end
