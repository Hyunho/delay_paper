require "lib/sensor_network"



puts "packet, distance, error_bound, window_size, raw, temporal ,prediction, delay sensor "
  puts 


def change_variable packet_size, distance, error_bound, window_size

  Node.packet_size = packet_size
  Node.distance = distance
  ApproximationSensor.error_bound = error_bound
  Config.sliding_window_size = window_size
  
  def run sensor_class
    
    network = SensorNetwork.new
    network.deploy_nodes sensor_class
    
    for i in (1..10000 )
      puts i if i%1000 == 0

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


  puts " #{packet_size}, #{distance}, #{error_bound}, , #{window_size}, #{run(RawSensor)}, #{run(TemporalSensor)}, #{run(PredictionSensor)}, #{run(DelaySensor)}"


  # puts "packet = #{packet_size}, distance = #{distance}, error_bound =  #{error_bound}"
  # puts "delay sensor : #{run(DelaySensor)}, raw : #{run(RawSensor)},temporal : #{run(TemporalSensor)},  prediction : #{run(PredictionSensor)}"

end

change_variable(20, 20000, 0.1, 4)

# for window_size in [4, 8, 16]
#   for packet in [20, 10, 5]
#     for distance in [20, 10, 5]
#       for error_bound in [0.1, 1, 5]
#         change_variable(packet, distance, error_bound, window_size)
#       end
#     end
#   end
# end
  #
#
