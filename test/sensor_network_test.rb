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

class BaseSensorTest < Test::Unit::TestCase

  def setup
    datagen = DataGeneratorTest::DummyGenerator.new
    @sensor = BaseSensor.new(mote_id = 1, x= 10, y =11, datagen)
  end

  def sample
    assert_not_nil(@sensor.sample)
    assert_equal(0, @sensor.total_packet)
  end

  def test_transmitt
    BaseSensor.distance = 1

    BaseSensor.packet_size = 32
    @sensor.transmit Array.new(1)

    assert_equal(1, @sensor.sent_packet_count)

    assert_equal(Transmitter.energy_tx(@sensor.sent_packet_count * BaseSensor.packet_size, BaseSensor.distance), 
                 @sensor.consumed_energy)
  end

  def test_energy

    assert_equal(50*(10**(-9)) + 100*(10**(-12)),
                 Transmitter.energy_tx(bit_size = 1, distance =1))

    assert_equal(2 * 50 * (10**(-9)) + 2 * (2**2) * 100*(10**(-12)), 
                 Transmitter.energy_tx(bit_size = 2, distance =2))

  end
end

class SubSensorTest < Test::Unit::TestCase

  def setup
    @datagen = DataGeneratorTest::DummyGenerator.new
  end

  def test_raw_sensor
    sensor = RawSensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(10, sensor.sent_count)
  end

  def test_temporal_sensor 
    sensor = TemporalSensor.new(mote_id = 1, x= 10, y= 11, @datagen, error_bound =3)
    (1..10).each {sensor.forward}
    assert_equal(4, sensor.sent_count)   
  end

  def test_prediction_sensor
    sensor = PredictionSensor.new(mote_id = 1, x= 10, y= 11, @datagen, error_bound =3)
    (1..10).each {sensor.forward}
    assert_equal(3, sensor.sent_count)   
  end

  def test_delay_sensor

    sensor = DelaySensor.new(mote_id = 1, x= 10, y= 11, @datagen, error_bound =3)
    (1..10).each {sensor.forward}
    assert_equal(2, sensor.sent_count)   
  end
end



class DataGeneratorTest < Test::Unit::TestCase
  class DummyGenerator < DataGenerator

    def initialize 
      @data = (11..20).map { |index| index}
    end
    
    def read
      @data.slice!(0).to_f
    end
  end
  
  def test_generate
    gen = DataGenerator.new(file_name= "./resource/sensors/1.txt" )
    assert_not_nil(gen.read)   
    assert_equal(Float, gen.read.class)

    gen = DummyGenerator.new
    assert_equal(Float, gen.read.class)
  end
end

class SlidingWindowTest < Test::Unit::TestCase

  def testPutAndRemove
    sliding_window = SlidingWindow.new(width = 3)

    sliding_window.add Tuple.new(0, 10)
    sliding_window.add Tuple.new(1, 11)
    sliding_window.add Tuple.new(2, 12)
    sliding_window.add Tuple.new(3, 13)  
    assert_equal(1, sliding_window.tuples[0].time)
    assert_equal(3, sliding_window.tuples.size)
    sliding_window.add Tuple.new(4, 13) 
    assert_equal(3, sliding_window.tuples.size)  
    assert_equal(2, sliding_window.tuples[0].time)
   
  end
end
