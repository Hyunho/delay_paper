require "./lib/sensor_network"



puts "packet, distance, error_bound, window_size, raw, temporal ,prediction, delay sensor "


def change_variable packet_size, distance, error_bound, window_size

  Node.packet_size = packet_size
  Node.distance = distance
  ApproximationSensor.error_bound = error_bound
  DelaySensor.window_size = window_size
  
  def run sensor_class
    
    network = SensorNetwork.new
    network.deploy_nodes sensor_class
    
    for i in (1..1000)
      print "." if i%100 == 0

      network.nodes.values.each do |item|
        item.forward unless item.class == BaseStation
      end
    end
    
    sum = 0
    for node in network.nodes.values

      sum = sum + node.consumed_energy unless node.class == BaseStation


    end

    sum.to_f
  end


  puts " #{packet_size}, #{distance}, #{ApproximationSensor.error_bound}, #{window_size}, #{run(RawSensor).to_f}, #{run(TemporalSensor).to_f}, #{run(PredictionSensor).to_f}, #{run(DelaySensor).to_f}"



end

#change_variable(20, 20000, 0.1, 4)

error_bound = 10
distance = 12
window_size = 8
packet = 40


for error_bound in [0.1, 1, 10 ,25, 50]
   change_variable(packet, distance, error_bound, window_size)
end

error_bound = 10
distance = 12
window_size = 8
packet = 40

for distance in [6.001, 12, 18, 25]
  change_variable(packet, distance, error_bound, window_size)
end

error_bound = 10
distance = 12
window_size = 8
packet = 40

for window_size in [4, 8, 16,32]
  change_variable(packet, distance, error_bound, window_size)
end

error_bound = 10
distance = 12
window_size = 8
packet = 40

for packet in [24, 40, 56, 72]
  change_variable(packet, distance, error_bound, window_size)
end
