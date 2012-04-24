class Sensor

  attr_accessor :id, :sent_count
  
  def initialize(id = 0)
    @id = id
    @sample_data = Array.new
    @sent_count = 0
  end

  def sample_data= (data)
    @sample_data = data.reverse
  end

  def forward_step
    data = self.sample
    compute
    send(data)
  end

  def sample data
  end

  def compute 
  end
  
  def transmit(data)
    @sent_count = @sent_count +1
    BaseStation.instance.receive(data)
    
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

  # size is number of tuples in sliding window
  attr_accessor :size
  def initialize(width = 0)
    @data = Array.new
    @width = width
  end

  # when new tuple is added to sliding window, old tuple is removed by width
  def add tuple
    @data.push tuple

    max_time = 0
    for item in @data
      max_time = item.time > max_time ? item.time : max_time
    end

    @data.reject! do |item|
      item.time <= (max_time - width) ? true : false
    end
  end
  
  def size
    return @data.size
  end
end

require 'singleton'
class BaseStation 
  include Singleton

  @received_data

  def receive(data)
    @recieved_data = data
  end

  def received_data
    return @recieved_data

  end
end

