require 'compress'


allowed_error = 3

data = [1,2,3,4,5,6,6,7,2,3,4,23,5,6,36, 10]


regression_cofficient =  Compression.regression(data)
p Compression.max_error(data, Compression.inverse_regression(regression_cofficient,8))



haar_cofficient = Compression.haar_transform(data)
p Compression.max_error(data, Compression.inverse_haar_transform(haar_cofficient))

data =  (1..(128)).map {|b|"a"}




