require './lib/compress'
require 'singleton'

class SensorNetwork

  attr_accessor :nodes
  attr_accessor :base_station

  def initialize
    @nodes = Hash.new
    Node.sensor_network = self
  end

  # sensors and base_station is deployed in sensor networks
  def deploy_nodes sensor_class
    
    file = File.open("./resource/mote_locs.txt")
    @base_station = BaseStation.new(x = 39.5, y =30)
    @nodes["0"] = @base_station
   
    begin
      while line = file.readline

        words = line.split
        
        moteid = words[0]

        x = words[1].to_f
        y = words[2].to_f
        
        next if moteid == "5" or moteid == "15"
        
        datagen = DataGenerator.new "./resource/sensors/" + moteid + ".txt"
        @nodes[moteid] = sensor_class.new(moteid, x, y, datagen)
      end
    rescue EOFError
      file.close
    end
  end

  def add node

    if node.class == BaseStation
      
      @base_station = node
      @nodes["0"] = node
    else
      nodes[node.id] = node
    end
  end

  def all_routed? 
    temp = @nodes.values.reject {|node| node.hop != -1 }

    temp.size == 0 ? true : false
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
      value = words[6]
      value.to_f
    rescue EOFError
      @file.close      
      @is_alive = false
    end
  end
end


module Transmitter
  
  #getting energy to tranmit data
  def Transmitter.energy_tx(bit_size, distance)
    bit_size * 50*(10**(-9)) + bit_size * (distance**2) * 100*(10**(-12))
  end

  #getting energy to receive data
  def Transmitter.energy_rx(bit_size)
    bit_size * 50*(10**(-9))
  end

end


class Node

  class << self

    #communication distance
    attr_accessor :distance
    attr_accessor :packet_size 
    attr_accessor :sensor_network
  end


  attr_accessor :sent_count
  
  #getting packet count which is sent
  attr_accessor :sent_packet_count

  #position of sensor
  attr_accessor :x, :y
  attr_accessor :hop
  
  attr_accessor :broadcast_count

  def initialize(x, y)
    @x = x
    @y = y
    @hop = -1

    Node.distance = 1 if Node.distance.nil?
    @broadcast_count = 0
    @consumed_energy = 0
    @sent_packet_count = 0
  end

  
  def charge_tx_cost data

    @sent_packet_count = @sent_packet_count + self.data_to_packet_count(data)
    
    @consumed_energy = @consumed_energy + 
      Transmitter.energy_tx(data_to_packet_count(data) * Node.packet_size, Node.distance)
  end
  
  
  def data_to_packet_count data
    bit_size = data.size * 32
    packet_count = (bit_size.to_f / Node.packet_size.to_f).to_f.ceil
  end
  
  def charge_rx_cost data
    @consumed_energy = @consumed_energy +
      Transmitter.energy_rx(data_to_packet_count(data) * Node.packet_size)
  end
 

  def neighbors
    neighbors = Array.new
    for node in Node.sensor_network.nodes.values      
      distance = Math.sqrt((@x - node.x)**2 + (@y - node.y)**2)
      if distance < Node.distance and node != self
        neighbors << node
      end
    end
    neighbors
  end

  def no_hop_neighbors
    no_hop = Array.new
    for node in self.neighbors
      if node.hop == -1
        no_hop << node
      end
    end
    no_hop
  end

  def parents
    parents = Array.new
    for node in self.neighbors
      if node.hop < @hop
        parents << node
      end
    end
    parents
  end

  def children
    children = Array.new

    for node in self.neighbors
      if node.hop > @hop
        children << node
      end
    end

    children
  end
  

  
  def consumed_energy
    @consumed_energy
  end 
  
  def receive message
    charge_rx_cost message[:data]
  end


end

class BaseStation < Node
  
  attr_accessor :sensor_data

  def initialize(x,y)
    super
    @sensor_data = {}
    @hop = 0
  end
  
  def routing_down
    queue= Array.new
    queue.insert(0, self)
    until queue.empty?
      node = queue.pop
      
      node.broadcast_count = node.broadcast_count + 1
      no_hop_neighbors = node.no_hop_neighbors
      
      for no_hop in no_hop_neighbors
        no_hop.hop = node.hop + 1
        queue.insert(0,no_hop)
      end
    end
  end
  
  def receive message
    super
    id = message[:id]
    sensor_data[id] = message[:data]
  end

end


class BaseSensor < Node

  attr_accessor :id
 
  def initialize(id, x, y, datagen)
    super(x,y)

    @id = id
    @data_generator = datagen

    @is_alive = true
    @time = 0 

    Node.packet_size = 1 if Node.packet_size.nil?

    @sent_count = 0    
    @sent_packet_count = 0

  end


  def forward
    value = self.sample
    data = compute value

    unless data.size == 0
      @sent_count = @sent_count + 1
      routing_up ({:id => @id, :data => data})
    end
  end

  def sample 
    @time = @time + 1
    @data_generator.read
  end

  def compute value
    [value]
  end
  
  def routing_up message

    queue= Array.new
    queue.insert(0, self)
    
    until queue.empty?
      node = queue.pop

      node.broadcast_count = node.broadcast_count + 1
      node.charge_tx_cost message[:data]
      parents = node.parents

      for par in parents

        par.receive message
        queue.insert(0,par)
      end
    end
  end


end

class RawSensor < BaseSensor

end

class ApproximationSensor < BaseSensor
  class << self
    attr_accessor :error_bound
  end

  def initialize(id, x, y, datagen)
    super(id, x, y, datagen)
    ApproximationSensor.error_bound = 3 if ApproximationSensor.error_bound.nil?
  end
end


class TemporalSensor < ApproximationSensor
  @sent_value

  def initialize(id, x, y, datagen)
    super
    @sent_value =0
  end
  
  def compute value
    if (@sent_value - value).abs < ApproximationSensor.error_bound
      return []
    else
      @sent_value = value
      [value]
    end
  end
end


class PredictionSensor < ApproximationSensor

  def initialize(id, x, y, datagen)
    super
    @alpha = 0
    @beta = 0


    width = 3

    @sliding_window = SlidingWindow.new(width)
  
  end

  def compute value
    @sliding_window.add Tuple.new(@time, value)
    if ((@alpha * @time +  @beta) - value).abs < ApproximationSensor.error_bound
      return []
    else
      @alpha, @beta = Compression.regression(@sliding_window.tuples) if @sliding_window.tuples.size > 2
      return [value]
    end
  end
end

class DelaySensor < ApproximationSensor
  

  class << self
    attr_accessor :window_size
  end
  def initialize(id, x, y, datagen)
    super

    DelaySensor.window_size = 4 if DelaySensor.window_size.nil?

    @alpha = 0
    @beta = 0

    @sliding_window = SlidingWindow.new(DelaySensor.window_size)
    @sent_period = @time
  end
  
  def compute value

    @sliding_window.add Tuple.new(@time, value)


    if ((@alpha * (@time - @sliding_window.width + 1) +  @beta) - @sliding_window.tuples[0].value).abs < ApproximationSensor.error_bound or @time - @sliding_window.width < @sent_period
      return []
    else
    
      array =  @sliding_window.tuples.map { |tuple| tuple.value}

      wavelet = Compression::HaarWavelet.new(array)
      wavelet.reduction(ApproximationSensor.error_bound)

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

    # throw "slding window has to eqale 2^n, but given width is #{width}" if 
    #   Math.log2(width) == Math.log2(width).to_i
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

