require_relative '../db/bar_db_reader.rb'
require_relative 'indicator_runner.rb'

module Guustock
  class IndicatorViewer

    attr_reader :bar_sequence

    def initialize(indicator_name)
      @indicator_name = indicator_name
      @bar_sequence = []
    end

    def view(id, periods = [5,30], start_time = Time.at(0), end_time = Time.mktime(3000))
      runner = IndicatorRunner.new(@indicator_name, true)
      db_reader = BarDbReader.instance
      db_reader.forward_each(id, start_time, periods) do |bars|
        #puts bars[0]
        break if bars[0].time>=end_time
        @bar_sequence << bars
        bars.each do |bar|
          runner.add(bar)
        end   
      end

      @bar_sequence.each do |bars|
        bars.each do |bar|
          puts "V : #{bar}"
        end
      end

    end
  end

end

