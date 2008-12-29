$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_graph/active_record_extension'
require 'rubygems'
require 'activesupport'

module ActiveGraph
  VERSION = '0.0.2'
  
  DEFAULT_START = 0
  DEFAULT_END = 7
  DEFAULT_TYPE = :bar
  DEFAULT_STEP = 1
  DEFAULT_X_AXIS_INTERVAL = 1
  DEFAULT_X_AXIS_METHOD = Proc.new {|x| "#{x} - #{x + ActiveGraph::DEFAULT_X_AXIS_INTERVAL}"}
  DEFAULT_WIDTH=400
end
