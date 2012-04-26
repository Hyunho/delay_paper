require './lib/sensor_network'
require 'test/unit'

class SensorNetworkTest < Test::Unit::TestCase

  def test_deploy
    network = SensorNetwork.new
    assert_equal(0, network.sensors.size)
    assert_equal(nil, network.base_station)
 
    network.deploy_nodes
    assert_not_nil(network.base_station)
    assert_equal(54, network.sensors.size)
  end
end

class SensorTest < Test::Unit::TestCase
  def test_initialize
    sensor = Sensor.new(mote_id = 10, x= 10, y =1)
    assert_not_nil(sensor.sample)
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

