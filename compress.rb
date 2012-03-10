require 'matrix'

def haar2(matrix_data)
  wavelet_matrix = Matrix[[1,1],[1,-1]]
  return matrix_data * wavelet_matrix
end

def fast_haar_transform_on_row matrix_data
  sum_matrix = Matrix.column_vector([1, 1])
  different_matrix = Matrix.column_vector([1, -1])
  average_signal = matrix_data  * sum_matrix 
  detail_signal = matrix_data  * different_matrix 
  
  Matrix.row_vector[average_signal.to_a, detail_signal.to_a]
end


def average_signal matrix
  sum_matrix = Matrix[[1], [1]]
  return matrix * sum_matrix
end

def detail_signal matrix
  different_matrix = Matrix[[1], [-1]]
  return matrix * different_matrix 
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
