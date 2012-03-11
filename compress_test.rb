require 'compress'
require 'test/unit'
require 'matrix'
class CompressionTest < Test::Unit::TestCase

  def test_convert
    assert_equal([2,3], Matrix.to_1D_array(Matrix.row_vector([2,3])))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3],[3,4]]))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3,3,4]]))
  end


  def test_haar_transform

    test_data = [ 2, 4, 6, 3, 1, 2, 5, 9,
                  8,13,15, 7, 8, 9, 0, 4]
   

    
    assert_equal([3, 4.5, 1.5, 7, 10.5, 11, 8.5, 2,
                  -1, 1.5, -0.5, -2, -2.5, 4, -0.5, -2], 
                 Compression.fast_haar_transform(test_data))
                  
    assert_equal([3.75, 4.25, 10.75, 5.25, -0.75, -2.75, -0.25, 3.25],
                 Compression.modified_fast_haar_transform(test_data))
    
  end

  def test_regression
    test_data = [1,2,3,4,5,6,7,8]
    assert_equal([0.0, 1.0], Compression.regression(test_data))
  end
end
