require 'matrix'


class Array

  def Array.fast_haar_transform array
    average_signal = (1..array.size/2).map {|n| (array[(2*n-2)] + array[2*n-1]) /2.0 }
    detail_signal = (1..array.size/2).map {|n| (array[(2*n-2)] - array[2*n-1]) / 2.0 }
    return average_signal + detail_signal
  end

  def Array.modified_fast_haar_transform array
    average_signal = (1..array.size/4).map do |n|
      ((array[(4*n-4)] + array[4*n-3] + array[4*n-2] + array[4*n-1])) / 4.00
    end

    detail_signal = (1..array.size/4).map do |n|
      ((array[(4*n-4)] + array[4*n-3]) - (array[4*n-2] + array[4*n-1])) / 4.00
    end

    return average_signal + detail_signal
  end

  def Array.regression array
    
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
    return [hat_a, hat_b]
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

