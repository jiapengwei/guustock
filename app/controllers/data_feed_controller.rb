require 'guustock/db/bar_db_reader'
require 'guustock/indicator/indicator_viewer'

class DataFeedController < ApplicationController
  respond_to :json
  include Guustock
  def bar
    @id = params['id']
    @year = params['year'].to_i
    @month = nil
    @day = nil
    @month = params['month'].to_i unless params['month'].nil?
    @day = params['day'].to_i unless params['day'].nil?
    @period = params['period']
    @period = "5" if @period.nil?
    @period = @period.to_i
    periods = [@period]
    db_reader = BarDbReader.instance
    start_time = Time.mktime(@year)
    if !@day.nil?
      end_time = Time.mktime(@year, @month, @day+1)
    elsif !@month.nil?
      end_time = Time.mktime(@year, @month+1, @day)
    elsif !@year.nil?
      end_time = Time.mktime(@year+1, @month, @day)
    end
    @bar_array = []
    @data_array = []
    db_reader.forward_each(@id, start_time, periods) do |bars|
      #puts bars[0]
      #puts bars.size
      bar = bars[0]
      break if bar.time>=end_time
      @bar_array << bar
      #data = [bar.time.to_i*1000, bar.start, bar.high, bar.low, bar.close, bar.vol, bar.period]
      data = [(bar.time.to_i+8*3600)*1000, bar.start, bar.high, bar.low, bar.close, bar.vol]
      @data_array << data
    end
    #render :bar, :layout => false
    render :json => @data_array
  end

  def fenxing
    @id = params['id']
    @year = params['year'].to_i
    @month = nil
    @day = nil
    @month = params['month'].to_i unless params['month'].nil?
    @day = params['day'].to_i unless params['day'].nil?
    @period = params['period']
    @period = "5" if @period.nil?
    @period = @period.to_i
    periods = [@period]
    db_reader = BarDbReader.instance
    start_time = Time.mktime(@year, @month, @day)
    if !@day.nil?
      end_time = Time.mktime(@year, @month, @day+1)
    elsif !@month.nil?
      end_time = Time.mktime(@year, @month+1, @day)
    elsif !@year.nil?
      end_time = Time.mktime(@year+1, @month, @day)
    end
      
    viewer = IndicatorViewer.new("fenxing")
    viewer.view(@id, periods, start_time, end_time)
    @data_array = []
    viewer.bar_sequence.each do |bars|
      #puts bars[0]
      #puts bars.size
      bar = bars[0]
      #puts "vol:#{bar.vol}"
      data = [(bar.time.to_i+8*3600)*1000, bar.start, bar.high, bar.low, bar.close, bar.vol]
      fenxingk = bar.indicator['fenxingk']
      fenxing = bar.indicator['fenxing']
      unless fenxingk.nil?
        start = fenxingk.low
        close = fenxingk.high
        if fenxingk.direction == DIRECTION_DOWN
          start = fenxingk.high
          close = fenxingk.low
        end
        data.concat([start, fenxingk.high, fenxingk.low, close, fenxing])
      end
      @data_array << data
    end
    #render :bar, :layout => false
    render :json => @data_array
  end
end
