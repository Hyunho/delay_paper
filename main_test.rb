require 'main'
require 'test/unit'

class MainTest < Test::Unit::TestCase

  def setup
    @base_station = BaseStation.instance
    @sensor = Sensor.new
  end

  def teardown
  end

  def test_sampling
    sensor = Sensor.new
    data = sensor.sample
    assert_nil(data)
    
    sensor.sample_data = [1,2,3,4,5]
    for expected_data in 1..5
      assert_equal(expected_data, sensor.sample)
    end
    assert_nil(sensor.sample)
 end

  def test_computation
  end
    
  def test_communication
    @base_station.receive(3)
    assert_equal(3, @base_station.received_data) 
    
    @sensor.send(2)
    assert_equal(2, @base_station.received_data)
  end

end



