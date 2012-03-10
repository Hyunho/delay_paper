require 'compress'
require 'test/unit'
require 'matrix'
class CompressTest < Test::Unit::TestCase

  def setup
    @test_data1 = [1,2,3,4,5,6,7,8]
  end


  def test_haar


    assert_equal(Matrix[[5]], average_signal(Matrix[[2,3]]))
    assert_equal(Matrix[[-1]], detail_signal(Matrix[[2,3]]))

    assert_equal(Matrix[[3, 7]], average_signal(Matrix[[1,2,3,4]]))
    assert_equal(Matrix[[3, 7]], detail_signal(Matrix[[1,2,3,4]]))



#    assert_equal(Matrix.row_vector([5, -1]), haar2(Matrix.row_vector([2, 3])))
#    assert_equal(Matrix.row_vector([5, -1]), fast_haar_transform_on_row(Matrix.row_vector([2, 3])))

    test_data = [3,7,5,2,8,5,4,1]
#    assert_equal([35, -1, 3, 8, -4, 3, 3, 3, 3], haar4(test_data))


    test_data = [ 2, 4, 6, 3,
                  1, 2, 5, 9,
                  8,13,15, 7,
                  8, 9, 0, 4]


  end

  def test_regression
#    assert_equal([1,1],regression(@test_data1))
  end
end






