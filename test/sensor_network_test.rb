require '../lib/sensor_network'
require 'test/unit'

class SensorNetworkTest < Test::Unit::TestCase

  #= it's for the estimation model
  def testSensores
    
    data =  [1,2,3,4,3,3,2,4]
    sensor = Sensor.new  
    base_station = BaseStation.instance
    
    # until 1 > data.size
    #   sensor.sample data.slice! 0
    #   sensor.compute
    #   sensor.transmit
    # end
    

  end
  
  
  # it's for haar wavlet data reduction
  def test2
    @data = [11, -1 ,-6 ,8 ,-2 ,6 ,6 ,10]

  end
end


class SlidingWindowTest < Test::Unit::TestCase

  def testPutAndRemove
    slidingWindow = SlidingWindow.new(width = 3)

    slidingWindow.add Tuple.new(0, 10)
    slidingWindow.add Tuple.new(1, 11)
    slidingWindow.add Tuple.new(2, 12)
    slidingWindow.add Tuple.new(3, 13)   
    assert_equal(3, slidingWindow.size)
    slidingWindow.add Tuple.new(4, 13) 
    assert_equal(3, slidingWindow.size)  
    
  end

  
end


class BaseStationTest 
end

