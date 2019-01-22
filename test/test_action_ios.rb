# frozen_string_literal: true

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/loco' # import the actual plugin
require 'minitest/autorun'
require 'webmock/minitest'
require 'plist'

# Class for testing the android action for simple cases
class ActionSimpleTest < Minitest::Test
  # Disable Network connection
  def setup
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Delete generated files
  def teardown
    FileUtils.remove_dir('test/results', true)
  end

  # Simplest case test
  def test_simple
    stub_request(:get, 'https://localise.biz/api/export/locale/en.strings?key=dummy1')
      .to_return(body: File.read('test/res/en.lproj/Localizable.strings'))
    stub_request(:get, 'https://localise.biz/api/export/locale/en.stringsdict?key=dummy1')
      .to_return(body: File.read('test/res/en.lproj/Localizable.stringsdict'))

    Fastlane::Actions::LocoAction.run(conf_file_path: 'test/res/LocoFile.simple.ios.yml')

    # Checking strings
    path = 'test/results/en.lproj/Localizable.strings'
    assert File.exist?(path), 'Could not find strings file'

    content = File.read path

    lines = content.split("\n")
    assert_equal ' * Fastlane Loco export: iOS strings',
                 lines[1]

    assert_equal 27,
                 lines.reject { |line| /^".*" = ".*";$/.match(line).nil? }.count

    # Checking plurals

    path = 'test/results/en.lproj/Localizable.stringsdict'
    assert File.exist?(path), 'Could not find stringsdict file'

    plist = Plist.parse_xml path
    assert_equal Hash,
                 plist.class

    assert_equal 8,
                 plist.count
  end
end
