require 'matrix'

module Compression

  def Compression.haar_transform array
    array = array.clone
    result = Array.new

    while(array.size > 1)
      average_signal = (1..array.size/2).map {|n| (array[(2*n-2)] + array[2*n-1]) /2.0 }
      detail_signal = (1..array.size/2).map {|n| (array[(2*n-2)] - array[2*n-1]) / 2.0 }  
      result = detail_signal + result
      array = average_signal
    end
    return result = array + result 
  end
  
  def Compression.inverse_haar_transform array
    array = array.clone

    average_signal = Array.new
    detail_signal = Array.new
    
    average_signal << array.slice!(0)
    while(!array.empty?)    
      detail_signal =  array.slice!(0, average_signal.size)

      temp = Array.new
      (1..average_signal.size).each do |i|
        temp << average_signal[i-1] + detail_signal[i-1]
        temp << average_signal[i-1] - detail_signal[i-1]
      end
      average_signal = temp
    end
    return average_signal   
  end

  def Compression.max_error_for_haar (haar_cofficient, original)
    transformed_data = Compression.inverse_haar_transform(haar_cofficient)

    max_error = 0
    transformed_data.each_index do |index|
      error = (original[index] - transformed_data[index]).abs
      if ( error > max_error)
        max_error = error
      end
    end

    return max_error
  end

  def Compression.regression array    
    sum_v = array.reduce(:+)
    mean_v = sum_v.to_f / array.size.to_f 

    sum_t = (1..array.size).reduce(:+)
    mean_t = sum_t.to_f / array.size.to_f
    
    numerator = 0
    (1..array.size).each do |i|
      t=i 
      numerator = numerator + (t - mean_t) *(array[i-1] - mean_v)
    end

    denominator = 0
    (1..array.size).each do |i|
      t = i
      denominator = denominator + (t - mean_t)**2
    end

    hat_b = numerator / denominator 
    hat_a = mean_v - hat_b * mean_t
    
    return cofficient = { "hat_a" => hat_a , "hat_b" => hat_b}
  end

  def Compression.max_error_for_regression(cofficient, data)
    max_error = 0
    (1..data.size).each do |i|
      t = i
      estimation_value = cofficient["hat_a"] + cofficient["hat_b"] * t
      error = (estimation_value - data[i-1]).abs
      if error > max_error
        max_error = error
      end
    end
    return max_error
  end
end

class Matrix
  def Matrix.to_1D_array matrix
    queue = Array.new
    result = Array.new
    queue.insert(0, matrix.to_a)

    # using breadth first search 
    while !queue.empty?
      item = queue.pop
      if item.class == Array
        item.each do |vertex|
          queue.insert(0, vertex)
        end  
      else
        result << item
      end
    end
    return result
  end
end

