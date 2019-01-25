# frozen_string_literal: true

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/loco' # import the actual plugin
require 'minitest/autorun'
require 'webmock/minitest'
require 'fileutils'
require_relative 'shared'

# Class for testing the android action for simple cases
class ActionAndroidTest < Minitest::Test
  # Disable network connection
  def setup
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Delete generated files
  def teardown
    WebMock.reset!
    FileUtils.remove_dir(TEST_DIRECTORY, true)
  end

  def make_table(locales: ['en'], projects: [{ 'key' => 'dummy1' }])
    Loco::Table.new platform: Loco::PLATFORM_ANDROID,
                    directory: TEST_DIRECTORY,
                    locales: locales,
                    projects: projects,
                    mapping: nil
  end

  def stub(locale, key)
    stub_request(:get, "#{LOCO_URL}/#{locale}.xml?key=#{key}")
      .to_return(body: File.read("#{RES_DIR}/#{locale}.xml"))
  end

  # Simplest case test
  def test_simple
    stub 'en', 'dummy1'

    table = make_table

    table.load!

    # TODO: test table content

    table.write!

    path = TEST_DIRECTORY + '/values/strings.xml'
    assert File.exist? path

    content = File.read path

    lines = content.split("\n")

    assert_equal '<?xml version="1.0" encoding="utf-8"?>', lines[0]
    assert_equal '<!--', lines[1]
    assert_equal ' File: strings', lines[3]
    assert_equal ' Locale: en', lines[4]

    assert_equal 27, lines.select { |line| line.strip.start_with? '<string name=' }.count
    assert_equal 8, lines.select { |line| line.strip.start_with? '<plurals name=' }.count
  end

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
