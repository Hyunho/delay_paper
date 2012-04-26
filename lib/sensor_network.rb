require './lib/compress'

class SensorNetwork

  attr_accessor :sensors
  attr_accessor :base_station
  def initialize
    self.sensors = Hash.new
  end
  # sensors and base_station is deployed in sensor networks
  def deploy_nodes
    
    file = File.open("./resource/mote_locs.txt")
    self.base_station = BaseStation.new(x = 20, y =20)
   
    begin
      while line = file.readline

        words = line.split
        moteid = words[0]
        x = words[1]
        y = words[2]          
        
        datagen = DataGenerator.new "./resource/sensors/" + moteid + ".txt"
        sensors[moteid] = BaseSensor.new(moteid, x, y, datagen)
      end
    rescue EOFError
      file.close
    end
  end
end

class DataGenerator
  def initialize file_name
    @file = File.open(file_name)
  end

  def read
    begin
      line = @file.readline  
      words = line.split
      value = words[3]
      value.to_f
    rescue EOFError
      @file.close      
      @is_alive = false
    end
  end
end

class BaseSensor
  class << self
    attr_accessor :packet_size 
  end

  attr_accessor :id
  attr_accessor :x, :y
  attr_accessor :sent_count

  
  def initialize(id, x, y, datagen)
    @id = id
    @sent_count = 0
    @data_generator = datagen
    @is_alive = true;
    
    self.class.packet_size = 1

    @time = 0 
  end

  def forward
    value = self.sample
    data = compute value
    self.transmit data
  end


  def sample 
    @time = @time + 1
    @data_generator.read
  end

  def compute data    
    
  end
  
  def transmit data
    @sent_count = @sent_count + (data.size / self.class.packet_size)    
  end
end

class RawSensor < BaseSensor

  def forward
    value = self.sample
    data = compute value
    self.transmit data
  end

  def compute value
    [value]
  end
end

class ApproximationSensor < BaseSensor
  
  def initialize(id, x, y, datagen, error_bound)
    super(id, x, y, datagen)
    @error_bound = error_bound
  end
end


class TemporalSensor < ApproximationSensor
  @sent_value

  def initialize(id, x, y, datagen, error_bound)
    super
    @sent_value =0
  end
  
  def compute value
    if (@sent_value - value).abs < @error_bound
      return []
    else
      @sent_value = value
      [value]
    end
  end
end


class PredictionSensor < ApproximationSensor

  def initialize(id, x, y, datagen, error_bound)
    super
    @alpha = 0
    @beta = 0
    @sliding_window = SlidingWindow.new(width = 4)
  
  end

  def compute value
    @sliding_window.add Tuple.new(@time, value)
    if ((@alpha * @time +  @beta) - value).abs < @error_bound
      return []
    else
      @alpha, @beta = Compression.regression(@sliding_window.tuples) if @sliding_window.tuples.size > 2
      return [value]
    end
  end
end

class DelaySensor < ApproximationSensor

  def initialize(id, x, y, datagen, error_bound)
    super
    @alpha = 0
    @beta = 0

    @sliding_window = SlidingWindow.new(width = 4)
    @sent_period = @time
  end
  
  def compute value

    @sliding_window.add Tuple.new(@time, value)


    if ((@alpha * (@time - @sliding_window.width + 1) +  @beta) - @sliding_window.tuples[0].value).abs < @error_bound or @time - @sliding_window.width < @sent_period
      return []
    else
    
      array =  @sliding_window.tuples.map { |tuple| tuple.value}
      
      wavelet = Compression::HaarWavelet.new(array)
      wavelet.reduction @error_bound

      @sent_period = @time
      
      tuples = (0..@sliding_window.tuples.size - 1).map do |index|
        Tuple.new(@sliding_window.tuples[index].time, wavelet.data[index])
      end

      @alpha, @beta = Compression.regression(tuples)
      @sent_period = @time
      reduction_array =  wavelet.coefficients.reject {|item| item == 0}
      return [reduction_array]
    end
    return []
  end
end

class Tuple
  attr_accessor :time, :value
  def initialize time=0, value=0
    @time = time
    @value = value
  end
end


class SlidingWindow 

  # whenever new tuple arrived, old tuple which is removed by width
  attr_accessor :width
  attr_accessor :tuples

  # size is number of tuples in sliding window
  attr_accessor :size
  def initialize(width = 0)
    @tuples = Array.new
    @width = width
  end

  # when new tuple is added to sliding window, old tuple is removed by width
  def add tuple
    @tuples.push tuple

    max_time = 0
    for item in @tuples
      max_time = item.time > max_time ? item.time : max_time
    end

    @tuples.reject! do |item|
      item.time <= (max_time - width) ? true : false
    end
  end
  
end

class BaseStation 
  
  attr_accessor :x, :y

  def initialize(x, y)
    self.x = x
    self.y = y
  end

  def receive(data)
    @recieved_data = data
  end

  def received_data
    return @recieved_data
  end
end

