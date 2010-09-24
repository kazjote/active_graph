require 'rspec'
# optionally add autorun support
# require 'rspec/autorun'

Rspec.configure do |c|
  c.mock_with :rspec
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'active_graph'
