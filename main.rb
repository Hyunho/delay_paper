class Sensor

  attr_accessor :id

  def initialize(id = 0)
    @id = id
  end

  def forward_step
    sample
    comutation
    send
  end

  def sample
    return nil
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

