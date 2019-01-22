# frozen_string_literal: true

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/loco' # import the actual plugin
require 'minitest/autorun'
require 'webmock/minitest'
require 'fileutils'

# Class for testing the android action for simple cases
class ActionAndroidTest < Minitest::Test
  # Disable network connection
  def setup
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Delete generated files
  def teardown
    FileUtils.remove_dir('test/results', true)
  end

  # Simplest case test
  def test_simple
    stub_request(:get, 'https://localise.biz/api/export/locale/en.xml?key=dummy1')
      .to_return(body: File.read('test/res/en.xml'))

    Fastlane::Actions::LocoAction.run(conf_file_path: 'test/res/LocoFile.simple.android.yml')

    path = 'test/results/values/strings.xml'
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
end
