require './lib/compress'
require './lib/sensor_network'
require 'test/unit'

class ErrorTreeTest < Test::Unit::TestCase


  def setup
    @data = [11, -1, -6, 8, -2, 6, 6, 10]
    @coefficients  = [4,-1,2,-3,6,-7, -4, -2]
    @error_tree = ErrorTree.new(@data)

  end

  def test_make_tree

    assert_equal(@data, @error_tree.data_nodes.map { |node| node.value })
    assert_equal(@data, @error_tree.internal_nodes(0).leaves.map { |node| node.value })
    assert_equal(@coefficients , @error_tree.internal_nodes.map { |node| node.value})

    assert_equal(2, @error_tree.internal_nodes(index=2).value)
    assert_equal(-6, @error_tree.data_nodes(index=2).value)


   # Test to find leaves, leaf leaves or leaf leavs of given node with a index 
    assert_equal([11, -1, -6, 8], @error_tree.internal_nodes(index=2).leaves.map { |node| node.value })
    assert_equal([11, -1], @error_tree.internal_nodes(index=2).left_leaves.map { |node| node.value })
    assert_equal([-6, 8], @error_tree.internal_nodes(index=2).right_leaves.map { |node| node.value })

    assert_equal([11], @error_tree.internal_nodes(index=4).left_leaves.map { |node| node.value })
    
    assert_equal(8, @error_tree.internal_nodes(0).leaves.size)
  end

  # Test maximum potential absolute error
  def test_maximum_potential_absolute_error

    assert_equal(@coefficients.map do
                   |coefficient| coefficient.abs
                 end,                 
                 @error_tree.internal_nodes.map do |internal_node|
                   internal_node.maximum_potential_absolute_error
                 end)
    
    assert_equal(-1, @error_tree.minimum_MA_node.value)
    @error_tree.minimum_MA_node.discard
    assert_equal(-2, @error_tree.minimum_MA_node.value)
    @error_tree.minimum_MA_node.discard 
    @error_tree.minimum_MA_node.discard 
    
    assert_equal(3, @error_tree.max_error)    
  end

  def test_data_reduction
    error_bound = 4
    @error_tree.data_reduction(error_bound)
    assert_equal(true, @error_tree.max_error  < error_bound)
    
  end

  def test_discard
    @error_tree.internal_nodes(1).discard
    assert_equal([1, 1, 1, 1, 1, 1, 1, 1], @error_tree.data_nodes.map { |node| node.error })

    @error_tree.internal_nodes(0).discard
    assert_equal([3, 3, 3, 3, 5, 5, 5, 5], @error_tree.data_nodes.map { |node| node.error })
  end

end

class CompressionTest < Test::Unit::TestCase


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

  end

  def test_regression
    test_data = (1..10).map do |i|
      Tuple.new(i, i)
    end
    assert_equal([1.0, 0.0], Compression.regression(test_data))
  end
end

