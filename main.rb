require 'compress'



allowed_error = 3




data_size = 128
data =  data_size.times.map { 20 + rand(5)}

regression_cofficient =  Compression.regression(data)

p Compression.max_error(data, Compression.inverse_regression(regression_cofficient,8))

haar_cofficient = Compression.haar_transform(data)
haar_cofficient = haar_cofficient[0..(haar_cofficient.size/2-1)] + Array.new(haar_cofficient.size/2,0)

p Compression.max_error(data, Compression.inverse_haar_transform(haar_cofficient))




def evalutation_test data
  if e(haar(data)) > e(regression(data))
    puts 'haar wins'
  else
    puts 'regression wins'
  end
end




