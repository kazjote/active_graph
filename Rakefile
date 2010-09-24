%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/active_graph'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "active_graph"
    gemspec.summary = "Gem which makes filling data for Gruff graphs based on ActiveRecord objects much easier."
    gemspec.email = "kazjote@gmail.com"
    gemspec.homepage = "http://github.com/kazjote/active_graph"
    gemspec.authors = ["Kacper Bielecki"]

    gemspec.add_dependency "active_support", ">= 3.0.0"
    gemspec.add_dependency "metaid"
    gemspec.add_dependency "gruff", ">= 0.3.1"

    gemspec.add_development_dependency "rspec", ">= 2.0.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
