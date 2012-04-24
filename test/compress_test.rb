require '../lib/compress'
require '../lib/sensor_network'
require 'test/unit'

class ErrorTreeTest < Test::Unit::TestCase

  def test_node
    data_node = ErrorTree::DataNode.new
    data_node.value = 10
    data_node.value = 20
    assert_equal(10, data_node.error)
  end

  def test_error_tree
    data = [11, -1, -6, 8, -2, 6, 6, 10]
    coefficients  = [4,-1,2,-3,6,-7, -4, -2]

    error_tree = ErrorTree.new(data)
    assert_equal(data, error_tree.leaf_nodes.map { |node| node.value })
    assert_equal(coefficients , error_tree.internal_nodes.map { |node| node.value})

    assert_equal(2, error_tree.internal_nodes(index=2).value)
    assert_equal(-6, error_tree.leaf_nodes(index=2).value)

    # Test to find leaves which satisfy a index 
    assert_equal([11, -1, -6, 8], error_tree.leaves(index=2).map { |node| node.value })
    assert_equal([11, -1], error_tree.left_leaves(index=2).map { |node| node.value })
    assert_equal([-6, 8], error_tree.right_leaves(index=2).map { |node| node.value })
    
    # Test maximum potential absolute error
    assert_equal(2, error_tree.maximum_potential_absolute_error(index = 2))
    assert_equal(coefficients.map do
                   |coefficient| coefficient.abs
                 end,                 
                 (0..7).map do |k|
                   error_tree.maximum_potential_absolute_error(k) 
                 end)

    
  end

end

class CompressionTest < Test::Unit::TestCase


  def test_convert
    assert_equal([2,3], Matrix.to_1D_array(Matrix.row_vector([2,3])))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3],[3,4]]))
    assert_equal([2,3,3,4], Matrix.to_1D_array(Matrix[[2,3,3,4]]))
  end

  def test_haar

    assert_equal([7,1,1,0], Compression.haar_transform([9,7,6,6]))
    assert_equal([9,7,6,6], Compression.inverse_haar_transform([7,1,1,0]))

    test_data = {
      "original" => [3,7,5,2,8,5,4,1], 
      "cofficients" => [4.375,-0.125,0.75,2.0,-2.0,1.5,1.5,1.5],
      "4_top" => [4.375,-0.125,0.75,2.0, 0 ,0 ,0 ,0]
    }
               
    assert_equal(test_data["cofficients"], Compression.haar_transform(test_data["original"]))
    assert_equal(test_data["original"], Compression.inverse_haar_transform(test_data["cofficients"]))
    assert_equal(0, Compression.max_error(test_data["original"], Compression.inverse_haar_transform(test_data["cofficients"])))
  end

  def test_regression
    test_data = (1..10).map do |i|
      Tuple.new(i, i)
    end
    assert_equal([1.0, 0.0], Compression.regression(test_data))
  end
end

