require 'rubygems'
require 'metaid'

module ActiveGraph
  module Support # :nodoc:
    def self.valualize(value_or_proc)
      value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc
    end
  end
  
  module ActiveRecordExtension
    # See README for examples and ActiveGraph for defaults.
    #
    # Available options are:
    # * :start - proc or value - first value taken into consideration while creating a graph
    # * :end - proc or value - last value
    # * :step - x-axis step
    # * :type - type of the graph (for example :line, :bar, see gruff documentation for other)
    # * :width - target width of the image
    # * :x_axis - options for x_axis
    # * :series - data series
    #
    # x_axis is a hash with following keys allowed:
    # * :interval - number of steps between two value labels
    # * :method - proc which creates the label for particular x point
    #
    # series is a hash, which keys are the symbols of data series and value is a hash with following keys:
    # * :value - symbol of the two argument method which gathers data for the graph
    # * :caption - caption
    def active_graph(name, options)
      graph_start = options[:start] || ActiveGraph::DEFAULT_START
      graph_end = options[:end] || ActiveGraph::DEFAULT_END
      graph_type = options[:type] || ActiveGraph::DEFAULT_TYPE
      width = options[:width] || ActiveGraph::DEFAULT_WIDTH
      step = options[:step] || ActiveGraph::DEFAULT_STEP
      x_axis_interval = (options[:x_axis] && options[:x_axis][:interval]) ||
        ActiveGraph::DEFAULT_X_AXIS_INTERVAL
      x_axis_method = (options[:x_axis] && options[:x_axis][:method]) ||
        ActiveGraph::DEFAULT_X_AXIS_METHOD
      series = options[:series]
      raise "You must provide at least one data serie" unless series.is_a?(Hash)
      
      graph_class = begin
        "Gruff::#{graph_type.to_s.camelize}".constantize
      rescue NameError
        raise "No such graph type '#{graph_type}'"
      end
      
      meta_def("#{name}_graph") do
        local_graph_start = Support.valualize(graph_start)
        local_graph_end = Support.valualize(graph_end)
        periods_count = ((local_graph_end - local_graph_start) / step).ceil
        g = graph_class.new(width)
        
        series.each_pair do |serie_name, serie_options|
          data_method = serie_options[:value]
          caption = serie_options[:caption]
          
          data = Array.new(periods_count) do |i|
            period_start = local_graph_start + i * step
            period_end = period_start + step
            send(data_method, period_start, period_end)
          end
          g.data(caption, data)
        end
        
        labels = Array.new((periods_count / x_axis_interval.to_f).ceil) do |i|
          period_start = local_graph_start + i * x_axis_interval * step
          label = x_axis_method.is_a?(Proc) ?
            x_axis_method.call(period_start) : self.send(x_axis_method, period_start)
          [i * x_axis_interval, label]
        end.flatten
        g.labels = Hash[*labels]
        g
      end
    end
  end
end
