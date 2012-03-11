require 'compress'
require 'test/unit'
require 'matrix'
class CompressionTest < Test::Unit::TestCase

  def test_convert
    assert_equal([2,3], Matrix.to_1D_array(Matrix.row_vector([2,3])))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3],[3,4]]))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3,3,4]]))
  end

  def test_compression

    assert_equal([7,1,1,0], Compression.haar_transform([9,7,6,6]))
    assert_equal([9,7,6,6], Compression.inverse_haar_transform([7,1,1,0]))

    test_data = {
      "original" => [3,7,5,2,8,5,4,1], 
      "haar_cofficient" => [4.375,-0.125,0.75,2.0,-2.0,1.5,1.5,1.5] }
               
    assert_equal(test_data["haar_cofficient"], Compression.haar_transform(test_data["original"]))
    assert_equal(test_data["original"], Compression.inverse_haar_transform(test_data["haar_cofficient"]))
    assert_equal(0, Compression.max_error_for_haar(test_data["haar_cofficient"],test_data["original"]))

    test_data = [1,2,3,4,5,6,7,8]
    cofficient = {"hat_a" => 0.0, "hat_b" => 1.0}
    assert_equal(cofficient, Compression.regression(test_data))
    assert_equal(0, Compression.max_error_for_regression(cofficient, test_data))
    assert_equal(1, Compression.max_error_for_regression(cofficient, [1,2,3,5]))
  end
end


def do_test
  test_data = [1,2,3,4,5,6,7,8]
  p Compression.regression(test_data)
end


ERROR_BOUND = 3

