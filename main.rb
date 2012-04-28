require "lib/sensor_network"



puts "packet, distance, error_bound, raw ,temporal ,prediction, delay sensor "
  puts 


def change_variable packet_size= 20, distance= 10, error_bound = 0.1

  Node.packet_size = packet_size
  Node.distance = distance
  ApproximationSensor.error_bound = error_bound
  
  def run sensor_class
    
    network = SensorNetwork.new
    network.deploy_nodes sensor_class
    
    for i in (1..500 )
#      puts i if i%100 == 0
      network.nodes.values.each do |item|
        item.forward unless item.class == BaseStation
      end
    end
    
    sum = 0
    for node in network.nodes.values
      sum = sum + node.consumed_energy unless node.class == BaseStation
    end
    
    sum
  end


   puts " #{packet_size}, #{distance}, #{error_bound}, #{run(DelaySensor)}, #{run(RawSensor)}, #{run(TemporalSensor)}, #{run(PredictionSensor)}"


  # puts "packet = #{packet_size}, distance = #{distance}, error_bound =  #{error_bound}"
  # puts "delay sensor : #{run(DelaySensor)}, raw : #{run(RawSensor)},temporal : #{run(TemporalSensor)},  prediction : #{run(PredictionSensor)}"

end


for packet in [20, 10, 5]
  for distance in [20, 10, 5]
    for error_bound in [0.1, 1, 5]
      change_variable packet, distance, error_bound
    end
  end
end
  #
#
#
# def execute sensor

#   gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")

  
#   for i in (1..30000 )
#     sensor.forward
#   end
  
#   b= {:sent_count => sensor.sent_count,
#     :sent_packet_count => sensor.sent_packet_count,
#     :consumed_energy => sensor.consumed_energy
#   }
#   p  b
# end

# gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
# sensor = RawSensor.new(mote_id = 1, x= 10, y= 11, gen)
# execute sensor


# gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
# sensor = TemporalSensor.new(mote_id = 1, x= 10, y= 11, gen)
# execute sensor

# gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
# sensor = PredictionSensor.new(mote_id = 1, x= 10, y= 11, gen)
# execute sensor

# gen = DataGenerator.new(file_name = "./resource/sensors/1.txt")
# sensor = DelaySensor.new(mote_id = 1, x= 10, y= 11, gen)
# execute sensor
