

class SensorNetwork

  attr_accessor :sensors
  attr_accessor :base_station
  def initialize
    self.sensors = Hash.new
  end


  
  def deploy_nodes
    
    file = File.open("./resource/mote_locs.txt")
    self.base_station = BaseStation.new(x = 20, y =20)
   
    begin
      while line = file.readline

        words = line.split
        moteid = words[0]
        x = words[1]
        y = words[2]          
        sensors[moteid] = Sensor.new(moteid, x, y)
      end
    rescue EOFError

      file.close
    end

  end
end


class Sensor
  attr_accessor :id
  attr_accessor :x, :y
  attr_accessor :sent_count
  
  def initialize(id, x, y)
    @id = id

    @file = File.open("./resource/sensors/" + id.to_s + ".txt")

  end

  def forward_step
    data = self.sample
    compute
    send(data)
  end

  def sample 

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

class BaseStation 
  
  attr_accessor :x, :y

  def initialize(x, y)
    self.x = x
    self.y = y
  end

  @received_data

  def receive(data)
    @recieved_data = data
  end

  def received_data
    return @recieved_data

  end
end

