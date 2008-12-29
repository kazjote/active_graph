require File.dirname(__FILE__) + '/spec_helper.rb'

module Gruff
  module BasicMethods
    attr_accessor :labels
    attr_accessor :width
    
    def data(label, data); end
    
    def initialize(width)
      @width = width
    end
  end
  
  class Bar
    include BasicMethods
  end
  
  class Line
    include BasicMethods
  end
end

class ActiveGraphTestModel
  extend ActiveGraph::ActiveRecordExtension
  
  attr_accessor :start_time
  
  active_graph :posts,
    :series => {:submited_posts => {:value => :count_have_posts_between, :caption => "posts"}}
    
  active_graph :new_posts,
    :type => :line,
    :start => Proc.new {@@start_time}, :end => Proc.new { @@start_time + 1.week },
    :step => 1.day,
    :x_axis => {:interval => 3, :method => Proc.new {|time| time.strftime("%d-%m") }},
    :width => 100,
    :series => {:submited_posts => {:value => :count_have_posts_between, :caption => "posts"},
      :submited_posts2 => {:value => :count_have_posts2_between, :caption => "posts2"}}
    
  def self.count_have_posts_between(min, max); end
  def self.count_have_posts2_between(min, max); end
end

describe "ActiveGraph" do
  it "should define method for creating the graph" do
    ActiveGraphTestModel.respond_to?(:posts_graph).should be_true
  end
  
  describe "while based on defaults" do
    before do
      @graph = Gruff::Bar.new(400)
      Gruff::Bar.should_receive(:new).with(400).and_return(@graph)
      default_start = ActiveGraph::DEFAULT_START
      default_end = ActiveGraph::DEFAULT_END
      @number_of_periods = default_end - default_start
    end
    
    it "should gather data from default number of periods" do
      @number_of_periods.times do |i|
        ActiveGraphTestModel.should_receive(:count_have_posts_between).
          with(i, i+1)
      end
      ActiveGraphTestModel.posts_graph
    end
    
    it "should set correct labels" do
      labels = Hash[*Array.new(@number_of_periods) {|i| [i, "#{i} - #{i+1}"]}.flatten]
      ActiveGraphTestModel.posts_graph
      @graph.labels.should == labels
    end
    
    it "should set data properly" do
      @number_of_periods.times do |i|
        ActiveGraphTestModel.should_receive(:count_have_posts_between).
          with(i, i+1).and_return(i)
      end
      data = Array.new(@number_of_periods) {|i| i}
      @graph.should_receive(:data).with("posts", data)
      ActiveGraphTestModel.posts_graph
    end
    
    it "should create the graph" do
      ActiveGraphTestModel.posts_graph.should == @graph
    end
    
    it "should set default width" do
      ActiveGraphTestModel.posts_graph.width.should == 400
    end
  end
  
  describe "while used with all custom parameters" do
    before do
      @start_time = Time.now - 1.month
      ActiveGraphTestModel.send(:class_variable_set, :@@start_time, @start_time)
    end
    
    it "should raise error on unknown graph type" do
      lambda do
        ActiveGraphTestModel.active_graph :wrong_type,
          :type => :unknown,
          :series => {:submited_posts => {:value => :count_have_posts_between,
            :caption => "posts"}}
      end.should raise_error
    end
    
    it "should be possible to specify start and end options with proc and step with value" do
      7.times do |i|
        ActiveGraphTestModel.should_receive(:count_have_posts_between).
          with(@start_time + i.days, @start_time + (i + 1).days)
      end
      ActiveGraphTestModel.new_posts_graph
    end
    
    it "should set correct width" do
      ActiveGraphTestModel.new_posts_graph.width.should == 100
    end
    
    describe "and drawing the graph" do
      before do
        @graph = Gruff::Line.new(400)
        Gruff::Line.should_receive(:new).and_return(@graph)
      end
      
      it "should be possible to specify graph type" do
        ActiveGraphTestModel.new_posts_graph.class.should == Gruff::Line
      end
      
      it "should be possible to specify many series" do
        @graph.should_receive(:data).with("posts", an_instance_of(Array))
        @graph.should_receive(:data).with("posts2", an_instance_of(Array))
        ActiveGraphTestModel.new_posts_graph
      end
      
      it "should be possible to set x_axis interval" do
        ActiveGraphTestModel.new_posts_graph
        @graph.labels.keys.sort.should == [0, 3, 6]
      end
      
      it "should be possible to specify x_axis labeling method" do
        ActiveGraphTestModel.new_posts_graph
        @graph.labels.should == {0 => @start_time.strftime("%d-%m"),
          3 => (@start_time + 3.days).strftime("%d-%m"),
          6 => (@start_time + 6.days).strftime("%d-%m")}
      end
    end
  end
end
