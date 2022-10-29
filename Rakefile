# frozen_string_literal: true

require "rspec/core/rake_task"
require "standard/rake"

task default: %i[standard spec]

task :run do
  require "./lib/jatt"
end

RSpec::Core::RakeTask.new(:spec)
