require "active_graph"

ActiveRecord::Base.send(:extend, ActiveGraph::ActiveRecordExtension)