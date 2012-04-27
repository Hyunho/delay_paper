require "lib/sensor_network"


Node.packet_size = 20
Node.distance = 10
ApproximationSensor.error_bound = 0.1

 
def execute sensor

  gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")

  
  for i in (1..30000 )
    sensor.forward
  end
  
  b= {:sent_count => sensor.sent_count,
    :sent_packet_count => sensor.sent_packet_count,
    :consumed_energy => sensor.consumed_energy
  }
  p  b
end

gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
sensor = RawSensor.new(mote_id = 1, x= 10, y= 11, gen)
execute sensor


gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
sensor = TemporalSensor.new(mote_id = 1, x= 10, y= 11, gen)
execute sensor

gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
sensor = PredictionSensor.new(mote_id = 1, x= 10, y= 11, gen)
execute sensor

gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
sensor = DelaySensor.new(mote_id = 1, x= 10, y= 11, gen)
execute sensor
