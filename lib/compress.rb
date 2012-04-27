#!bin/ruby
# For wavelet-based data Reduction, we use error tree
#

module Compression


  class ErrorTree # for nested class
    
    
    class Node 
      
      # return the set of data nodes in the subtree rooted at internal node which matched with given index(k)
      def leaves 
        node = self
        
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
    end
    
    class InternalNode < Node
      attr_accessor :left_child, :right_child
      attr_accessor :value
      attr_accessor :index
      def children
        nodes = Array.new
        nodes << @left_child unless @left_child.nil?    
        nodes << @right_child unless @right_child.nil?
        return nodes
      end
      
      
      
      # return the set of data nodes in the left subtree rooted at node with which matched with given index(k)
      def left_leaves 
        node = self.left_child
        return node.leaves
      end
      
      # return the set of data nodes in the right subtree rooted at node with which matched with given index(k)
      def right_leaves 
        node = self.right_child
        return node.leaves
      end   
      
      #find node with index and make it to be zero
      def discard       
        self.leaves.map do |data_node|
          if self.left_leaves.index(data_node) or self.index == 0
            sign_factor = -1
          else
            sign_factor = +1
          end
          data_node.value = data_node.value + sign_factor * self.value
        end
        
        self.value = 0
      end
      # this mean internal nodes with index k will effect on the running synopsis, if descarded.
      def maximum_potential_absolute_error 
        errors = self.leaves.map do |data_node|
          if self.left_leaves.index(data_node) 
            sign_factor = -1
          else
            sign_factor = +1
          end
          
          (data_node.error - sign_factor * self.value).abs
        end
        return errors.max
      end
      
    end
    
    
    class DataNode < Node
      attr_accessor :value    
      def value= v
        @original_value = v if @original_value.nil?
        @value = v     
      end
      
      def error
        return (@original_value - @value).abs
      end
      
      def original_value
        return @original_value
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
      
      index = 0
      for node in self.internal_nodes
        node.index = index
        index = index + 1
      end
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
    
    private :leaves_rooted_at_node
    
    # find leaf nodes using breadth first search.
    # If user specify a index, find a node satisfied and return a node.
    # Otherwise return all leaf nodes.
    def data_nodes index = nil
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
    
    # get a node with minumim MA
    def minimum_MA_node
      
      min_node = nil
      
      non_zero_nodes = self.internal_nodes.reject do |node|
        node.value == 0 ? true : false
      end
      
      for node in non_zero_nodes
        if min_node == nil
          min_node = node
        else
          min_node =
            min_node.maximum_potential_absolute_error < node.maximum_potential_absolute_error ? min_node : node
        end        
      end
      
      min_node
    end
    
    
    #We reduce a size of internal node until satisfy error_bound
    def data_reduction error_bound
      while self.minimum_MA_node != nil and self.minimum_MA_node.maximum_potential_absolute_error < error_bound
        self.minimum_MA_node.discard
      end
    end
    
    #get maximum error among data node's error
    def max_error    
      errors = self.data_nodes.map do |node|
        node.error
      end
      errors.max
    end
  end


  class HaarWavelet
    
    def initialize(data)
      @error_tree = Compression::ErrorTree.new(data)    
    end

    def reduction error_bound
      @error_tree.data_reduction error_bound
    end
    
    def coefficients
      @error_tree.internal_nodes.map {|node| node.value}
    end

    def data
      @error_tree.data_nodes.map { |node| node.value}
    end
    
  end

  #reconsruct data using haar wavelet, this fuction reduce data size
  def Compression.haar_data_reduction data, error_bound

    error_tree = Compression::ErrorTree.new(data)    
    error_tree.data_reduction(error_bound)
    error_tree.internal_nodes.map {|node| node.value}
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
