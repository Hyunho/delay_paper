require './lib/sensor_network'
require 'test/unit'


class DummyGenerator < DataGenerator
  
  def initialize 
    @data = (11..20).map { |index| index}
  end
    
  def read
    @data.slice!(0).to_f
  end
end

class SensorNetworkTest < Test::Unit::TestCase

  def test_deploy

    network = SensorNetwork.new
    network.deploy_nodes RawSensor
    assert_not_nil(network.base_station)

    assert_equal(true,  network.nodes.size>2)
  end


  def test_routing
    
    network = SensorNetwork.new
    network.deploy_nodes RawSensor


    #in our test file, size of senser network is 41 * 31
    Node.distance = 6.001

    nodes = network.nodes
    network.base_station.x = network.nodes["4"].x
    network.base_station.y = network.nodes["4"].y

    network.base_station.routing_down


    assert_equal(true, network.all_routed?)

    

    node1 = network.nodes["16"];

    assert_equal(true, network.nodes["16"].consumed_energy == 0)
    data = node1.forward

    assert_equal(true, network.base_station.sensor_data["16"].size > 0)
    assert_equal(false, network.nodes["16"].consumed_energy == 0)

  end

  def test_routing2

    network = SensorNetwork.new

    station = BaseStation.new 100, 100
    near_sensor = BaseSensor.new 1 , 100, 190, nil
    far_sensor = BaseSensor.new 1 , 100, 300, nil

    Node.distance = 100

    network.add(far_sensor)
    network.add(near_sensor)
    network.add(station)
    assert_not_nil(network.base_station)

    assert_equal(0, station.hop)
    assert_equal(-1, near_sensor.hop)
    assert_equal(-1, far_sensor.hop)

    assert_equal(2, network.nodes.size)

    station.routing_down
    
    assert_equal(1, near_sensor.hop)
    assert_equal(0, station.hop)
    assert_equal(-1, far_sensor.hop)
  
  end

  def test_I_dont_know
  
    Node.packet_size = 32
    Node.distance = 100
    ApproximationSensor.error_bound = 10
    DelaySensor.window_size = 4

    network = SensorNetwork.new

    station = BaseStation.new 100, 100
    hop1 = BaseSensor.new 1 , 100, 190, DummyGenerator.new
    hop2 = BaseSensor.new 2 , 100, 210, DummyGenerator.new

    network.add(hop2)
    network.add(hop1)
    network.add(station)

    assert_equal(3, network.nodes.size)

    station.routing_down

    assert_equal(0, station.hop)
    assert_equal(1, hop1.hop)
    assert_equal(2, hop2.hop)

  end
end


class RouteTest < Test::Unit::TestCase

  def setup
    
    Node.packet_size = 32
    Node.distance = 100
    ApproximationSensor.error_bound = 10
    DelaySensor.window_size = 4
    
    @network = SensorNetwork.new
    
    @station = BaseStation.new 100, 100
    @hop1 = BaseSensor.new 1 , 100, 190, DummyGenerator.new
    @hop2 = BaseSensor.new 2 , 100, 210, DummyGenerator.new
    @hop3 = BaseSensor.new 3 , 100, 300, DummyGenerator.new

    @network.add(@hop2)
    @network.add(@hop3)    
    @network.add(@hop1)
    @network.add(@station)
    assert_equal(4, @network.nodes.size)


    assert_equal [@hop2, @station], @hop1.neighbors
    assert_equal [@hop2], @hop1.no_hop_neighbors


    @station.routing_down

    assert_equal(0, @station.hop)
    assert_equal(1, @hop1.hop)
    assert_equal(2, @hop2.hop)
    assert_equal(3, @hop3.hop)
    
    assert_equal [@station], @hop1.parents
    assert_equal [@hop2], @hop1.children

    assert_equal 1, @hop1.broadcast_count
    assert_equal 1, @hop3.broadcast_count
    assert_equal 1, @hop2.broadcast_count
  end

  def test_I_dont_know
    
    @hop3.forward

  
    assert_equal 2, @hop3.broadcast_count
    assert_equal 2, @hop2.broadcast_count
    assert_equal 2, @hop1.broadcast_count
    

  end
end

class NodeTest < Test::Unit::TestCase

  def test_node

    node = Node.new 10, 10

    node.receive ({:id => "1", :data => [1,2]})

    assert_equal false, node.consumed_energy == 0
  end
end

class BaseSensorTest < Test::Unit::TestCase

  def setup
    datagen = DummyGenerator.new
    @sensor = BaseSensor.new(mote_id = 1, x= 10, y =11, datagen)
  end

  def sample
    assert_not_nil(@sensor.sample)
    assert_equal(0, @sensor.total_packet)
  end

  def test_transmission_cost
    Node.distance = 1

    Node.packet_size = 32
    @sensor.charge_tx_cost [0]

    assert_equal(1, @sensor.sent_packet_count)

    assert_equal(Transmitter.energy_tx(@sensor.sent_packet_count * Node.packet_size, Node.distance), 
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
    @datagen = DummyGenerator.new
    
    ApproximationSensor.error_bound = 3
    DelaySensor.window_size = 4
  end

  def test_raw_sensor
    sensor = RawSensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(10, sensor.sent_count)
  end

  def test_temporal_sensor 
    sensor = TemporalSensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(4, sensor.sent_count)   
  end

  def test_prediction_sensor
    sensor = PredictionSensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(3, sensor.sent_count)   
  end

  def test_delay_sensor
    
    
    DelaySensor.window_size = 4
    sensor = DelaySensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(2, sensor.sent_count)   


    DelaySensor.window_size = 10
    sensor = DelaySensor.new(mote_id = 1, x= 10, y= 11, @datagen)
    (1..10).each {sensor.forward}
    assert_equal(0, sensor.sent_count)   

  end
end



class DataGeneratorTest < Test::Unit::TestCase
  
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
