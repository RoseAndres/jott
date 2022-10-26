# frozen_string_literal: true

require "rspec/core/rake_task"
require "standard/rake"

task default: %i[standard spec]

task :run do
  require "./lib/jott_app"

  JottApp.new.launch
end

RSpec::Core::RakeTask.new(:spec)
