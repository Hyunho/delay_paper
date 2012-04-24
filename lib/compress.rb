require 'matrix'


# For wavelet-based data Reduction, we use error tree
#
class ErrorTree # for nested class
   
  class Node
    attr_accessor :value
  end

  class InternalNode < Node
    attr_accessor :left_child, :right_child

    def children
      nodes = Array.new
      nodes << @left_child unless @left_child.nil?    
      nodes << @right_child unless @right_child.nil?
      return nodes
    end
  end


  class DataNode < Node    
    @original_value
    def value= v
      @original_value = v if @original_value.nil?
      @value = v     
    end

    def value 
      return @value
    end

    def error
      return (@original_value - @value).abs
    end
  end
end

class ErrorTree # For implementation

  # Make a error tree using given data
  def initialize data
    array = data.clone

    # Make data nodes 
    array = array.map do |average_signal|
      data_node = DataNode.new
      data_node.value = average_signal
      {
        "average_signal" => average_signal,
        "node" => data_node
      }      
    end

    # Make internal nodes which is wavelet coefficient 
    while array.size > 1
      array = (1..array.size/2).map do |n|
        internal_node = InternalNode.new
        internal_node.value = 
          detail_signal =
          (array[(2*n-2)]["average_signal"] - array[2*n-1]["average_signal"]) / 2.0

        internal_node.left_child = array[2*n-2]["node"]
        internal_node.right_child = array[2*n-1]["node"]
        
        {
          "average_signal" => ((array[2*n-2]["average_signal"] + array[2*n-1]["average_signal"]) / 2.0) ,
          "node" => internal_node
        }
      end            
    end
    @root = 1    
    @root = InternalNode.new 
    @root.value = array[0]["average_signal"]     
    @root.left_child = array[0]["node"]       
  end

  
  # return the set of data nodes in the subtree rooted at internal node which matched with given index(k)
  def leaves index
    node = self.internal_nodes(index)
    return leaves_rooted_at_node node
  end

  # return the set of data nodes in the left subtree rooted at node with which matched with given index(k)
  def left_leaves index
    node = self.internal_nodes(index).left_child
    return leaves_rooted_at_node node
  end

  # return the set of data nodes in the right subtree rooted at node with which matched with given index(k)
  def right_leaves index
    node = self.internal_nodes(index).right_child
    return leaves_rooted_at_node node
  end
  
  # return the set of data node in the subtree rooted at given node
  def leaves_rooted_at_node node
    #using breadth first search
    result = Array.new
    queue = Array.new # In this function, we handle a array as queue 
    queue.insert(0, node)
    while !queue.empty?
      node = queue.pop

      unless node.class == DataNode
        node.children.each {|node| queue.insert(0, node)}
      else
        result << node
      end

    end
    return result
  end

  # find leaf nodes using breadth first search.
  # If user specify a index, find a node satisfied and return a node.
  # Otherwise return all leaf nodes.
  def leaf_nodes index = nil
    return leaves_rooted_at_node @root if index.nil?

    
    result = Array.new
    queue = Array.new # In this function, we handle arrry as queue 

    queue.insert(0, @root)

    i = -1
    while !queue.empty?
      node = queue.pop
      
      if node.class == DataNode
        result << node        
        i = i + 1
        return node if i == index
      else
        node.children.each {|node| queue.insert(0, node)}  
      end
    end
    return result
  end

  # Find internal nodes using breath first search.
  # If user specify a index, this function find a node which match with index and return it.
  # Otherwise return all internal nodes.
  def internal_nodes index = -1
    result = Array.new
    queue = Array.new # In this function, we handle arrry as queue 

    queue.insert(0, @root)

    i = -1
    until queue.empty?
      node = queue.pop

      if node.class == InternalNode
        i = i+1
        return node if i == index
        result << node
        node.children.each {|node| queue.insert(0, node)}
      else # if class of node is Data Node, do nothing

      end
    end
    return result    
  end

  # this mean internal nodes with index k will effect on the running synopsis, if descarded.
  def maximum_potential_absolute_error k


    internal_node = self.internal_nodes(k)
    leaf_nodes = self.leaves(k)
    errors = leaf_nodes.map do |data_node|

      if self.left_leaves(k).index(data_node) 
        sign_factor = +1
      else
        sign_factor = -1
      end
      (data_node.error - sign_factor * internal_node.value).abs
    end
    return errors.max
  end
end

module Compression

  def Compression.haar_transform array
    array = array.clone
    result = Array.new

    while(array.size > 1)
      average_signal = (1..array.size/2).map {|n| (array[(2*n-2)] + array[2*n-1]) /2.0 }
      detail_signal = (1..array.size/2).map {|n| (array[(2*n-2)] - array[2*n-1]) / 2.0 }  
      result = detail_signal + result
      array = average_signal
    end
    return result = array + result 
  end
  
  def Compression.inverse_haar_transform array
    array = array.clone

    average_signal = Array.new
    detail_signal = Array.new
    
    average_signal << array.slice!(0)
    while(!array.empty?)    
      detail_signal =  array.slice!(0, average_signal.size)

      temp = Array.new
      (1..average_signal.size).each do |i|
        temp << average_signal[i-1] + detail_signal[i-1]
        temp << average_signal[i-1] - detail_signal[i-1]
      end
      average_signal = temp
    end
    return average_signal   
  end


  # return regression coefficient variables at given tuples
  def Compression.regression tuples

    sum_value = tuples.reduce(0) do |sum, tuple|
      sum + tuple.value
    end
    mean_value = sum_value.to_f / tuples.size.to_f

    sum_time = tuples.reduce(0) do |sum, tuple|
      sum + tuple.time
    end
    mean_time = sum_time.to_f / tuples.size.to_f

    denominator = tuples.reduce(0) do |sum, tuple|
      sum + (tuple.time - mean_time)**2
    end

    numerator = tuples.reduce(0) do |sum, tuple|
      sum + ((tuple.time - mean_time)*(tuple.value - mean_value))
    end

    a = numerator/ denominator
    b = mean_value - a * mean_time
    return a ,b
  end
end
