# frozen_string_literal: true

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/loco' # import the actual plugin
require 'minitest/autorun'
require 'webmock/minitest'
require 'plist'
require_relative 'shared'

# Class for testing the android action for simple cases
class ActionSimpleTest < Minitest::Test
  # Disable Network connection
  def setup
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Delete generated files
  def teardown
    WebMock.reset!
    FileUtils.remove_dir(TEST_DIRECTORY, true)
  end

  def make_table(locales: ['en'], projects: [{ 'key' => 'dummy1' }])
    Loco::Table.new platform: Loco::PLATFORM_IOS,
                    directory: TEST_DIRECTORY,
                    locales: locales,
                    projects: projects,
                    mapping: nil
  end

  def stub(locale, key)
    stub_request(:get, "#{LOCO_URL}/#{locale}.strings?key=#{key}")
      .to_return(body: File.read("test/res/#{locale}.lproj/Localizable.strings"))
    stub_request(:get, "#{LOCO_URL}/#{locale}.stringsdict?key=dummy1")
      .to_return(body: File.read("test/res/#{locale}.lproj/Localizable.stringsdict"))
  end

  # Simplest case test
  def test_simple
    stub 'en', 'dummy1'

    table = make_table

    table.load!

    # TODO: test table loaded strings

    table.write!

    # Checking strings
    path = TEST_DIRECTORY + '/en.lproj/Localizable.strings'
    assert File.exist?(path), 'Could not find strings file'

    content = File.read path

    lines = content.split("\n")
    assert_equal ' * Fastlane Loco export: iOS strings',
                 lines[1]

    assert_equal 27,
                 lines.reject { |line| /^".*" = ".*";$/.match(line).nil? }.count

    # Checking plurals

    path = TEST_DIRECTORY + '/en.lproj/Localizable.stringsdict'
    assert File.exist?(path), 'Could not find stringsdict file'

    plist = Plist.parse_xml path
    assert_equal Hash,
                 plist.class

    assert_equal 8,
                 plist.count
  end

  # Simplest case test
  def test_include
    stub 'en', 'dummy1'

    projects = [{ 'key': 'dummy1', 'includes': ['city_.*'] }]

    table = make_table projects: projects

    table.load!

    assert_equal 5, table.strings['en'].count
    table.strings['en'].each do |key, _value|
      assert key.start_with? 'city_', "#{key} does not start with city_"
    end
    assert_equal 0, table.plurals['en'].count
  end
end
