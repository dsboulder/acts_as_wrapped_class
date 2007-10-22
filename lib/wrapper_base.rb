class WrapperBase
  eval((public_instance_methods - ["__id__","__send__", "is_a?", "kind_of?", "hash", "class", "inspect"]).collect{|meth| "undef "+meth}.join("; "))

  # Create a wrapper, passing in an object to wrap
  def initialize(wrapped_object)
    @wrapped_object = wrapped_object
  end
  
  def hash
    @wrapped_object.hash
  end
  
  def ==(other)
    return false if self.class != other.class
    @wrapped_object == other._wrapped_object
  end
  
  def <=>(other)
    raise "Can't compare objects of different types" if self.class != other.class
    @wrapped_object <=> other._wrapped_object
  end
    
  def ===(other)
    return false if self.class != other.class
    @wrapped_object === other._wrapped_object
  end  
  
  # Provide access to the wrapped object
  def _wrapped_object
    @wrapped_object
  end 
  
  def self.wrapper_class?
    true
  end 
end