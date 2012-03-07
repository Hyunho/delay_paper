require 'main'
require 'test/unit'

#class Object < Test::Unit::TestCase end


class MainTest < Test::Unit::TestCase

  def setup
    @base_station = BaseStation.instance
    @sensor = Sensor.new
  end

  def teardown
  end

  def test_basic_function
    def test_sampling
      data = @sensor.sample
      assert_not_nil(data)
    end
    test_sampling

    def test_computation
    end
    
    def test_communication
       @base_station.receive(3)
      assert_equal(3, @base_station.received_data) 

      @sensor.send(2)
      assert_equal(2, @base_station.received_data)
    end
    test_communication 

  end
end

