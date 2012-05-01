require './lib/sensor_network'
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/spec'

describe SensorNetwork do

  it "should add basestation or sensor nodes" do
    network = SensorNetwork.new
    station = BaseStation.new 100, 100
    network.add station
  end

  it "should add sensor nodes" do
  end
end

class DummyGenerator < DataGenerator
  
  def initialize data 
    @data = data
  end
    
  def read
    @data.slice!(0).to_f
  end
end
class DummySensorNetworkTest < MiniTest::Unit::TestCase

  def test_dummy_routing
    Node.packet_size = 32
    Node.distance = 100
    ApproximationSensor.error_bound = 10
    DelaySensor.window_size = 4    
  
    @network = SensorNetwork.new
    
    @station = BaseStation.new 100, 100
    @hop1 = BaseSensor.new 1 , 100, 190, DummyGenerator.new((11..20).map { |index| index})
    @hop2 = BaseSensor.new 2 , 100, 190, DummyGenerator.new((11..20).map { |index| index})
    @hop3 = BaseSensor.new 3 , 100, 250, DummyGenerator.new((11..20).map { |index| index})

    @network.add(@hop2)
    @network.add(@hop3)    
    @network.add(@hop1)
    @network.add(@station)

    assert_equal(4, @network.nodes.size)

    assert_equal 3, @hop1.neighbors.size
    assert_equal 2, @hop1.no_hop_neighbors.size

    @station.routing_down

    assert_equal(0, @station.hop)
    assert_equal(1, @hop1.hop)
    assert_equal(1, @hop2.hop)
    assert_equal(2, @hop3.hop)
    
    assert_equal [@station], @hop1.parents
    assert_equal [@hop3], @hop1.children

    assert_equal 1, @hop1.broadcast_count
    assert_equal 1, @hop3.broadcast_count
    assert_equal 1, @hop2.broadcast_count

    @hop3.forward
    
    assert_equal 2, @hop3.broadcast_count
    assert_equal 2, @hop2.broadcast_count
    assert_equal 2, @hop1.broadcast_count    

    assert_equal (Transmitter.energy_tx 32, Node.distance), @hop3.consumed_energy
    assert_equal (Transmitter.energy_tx(32, Node.distance) +
                  Transmitter.energy_rx(32)), @hop2.consumed_energy

    assert_equal @hop2.consumed_energy, @hop1.consumed_energy

  end
  
end


class RealSensorNetworkTest < MiniTest::Unit::TestCase

  def test_deploy

    network = SensorNetwork.new
    network.deploy_nodes RawSensor
    assert(network.base_station != nil)

    assert_equal(true,  network.nodes.size>2)
  end


end


class RouteTest < MiniTest::Unit::TestCase

  def test_real_routing
    
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

end

class NodeTest < MiniTest::Unit::TestCase

  def test_node

    node = Node.new 10, 10

    node.receive ({:id => "1", :data => [1,2]})

    assert_equal false, node.consumed_energy == 0
  end
end

class BaseSensorTest < MiniTest::Unit::TestCase

  def setup
    datagen = DummyGenerator.new((11..20).map { |index| index})
    @sensor = BaseSensor.new(mote_id = 1, x= 10, y =11, datagen)
  end

  def sample
    assert_equal(@sensor.sample != nil)
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

class SubSensorTest < MiniTest::Unit::TestCase

  def setup
    @datagen = DummyGenerator.new((11..20).map { |index| index})
    
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



class DataGeneratorTest < MiniTest::Unit::TestCase
  
  def test_generate
    gen = DataGenerator.new(file_name= "./resource/sensors/1.txt" )
    assert(gen.read != nil)   
    assert_equal(Float, gen.read.class)

    gen = DummyGenerator.new((11..20).map { |index| index})
    assert_equal(Float, gen.read.class)
  end
end

class SlidingWindowTest < MiniTest::Unit::TestCase

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
