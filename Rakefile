# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning = false
end

task(default: %i[spec rubocop test])
