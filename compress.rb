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

def fast_haar_transform data
  sum_matrix = Matrix.column_vector([1, 1])
  different_matrix = Matrix.column_vector([1, -1])
  average_signal = matrix_data  * sum_matrix 
  detail_signal = matrix_data  * different_matrix 
  
  Matrix.row_vector[average_signal.to_a, detail_signal.to_a]
end

 


def regression(data)

  sum_v = 0
  for value in data
    sum_v = sum_v + value
  end
  mean_v = sum_v / data.size

  sum_t =0
  for i in 1..data.size
    sum_t = sum_t + i
  end
  mean_t = sum_t / data.size

  return [mean_v, mean_t]
end
