class Sensor

  attr_accessor :id
  
  def initialize(id = 0)
    @id = id
    @sample_data = Array.new
  end

  def sample_data= (data)
    @sample_data = data.reverse
  end

  def forward_step
    sample
    comutation
    send
  end

  def sample
    return @sample_data.pop
  end

  def compute 
  end
  
  def send(data)
    BaseStation.instance.receive(data)
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

