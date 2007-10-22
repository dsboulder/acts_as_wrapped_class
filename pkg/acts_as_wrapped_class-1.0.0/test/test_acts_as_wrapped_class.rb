require 'test/unit'
require File.dirname(__FILE__) + "/../lib/acts_as_wrapped_class"

class NotWrappedClass
  def method1
    6.383
  end
end

class SampleClass  #SampleClassWrapper
  acts_as_wrapped_class :methods => [:get_other_class, :other_method], :constants => [:API]

  API = 3.1415

  def get_other_class
    OtherClass.new(rand)
  end
  
  def other_method
    5.5
  end
  
  def unsafe_method
    666
  end
end

class OtherClass
  SAMPLE_CLASS = SampleClass.new
  
  acts_as_wrapped_class :methods => :all, :constants => :all

  attr_reader :value

  def initialize(val)
    @value = val
  end  
  
  def get_sample_classes
    [SampleClass.new] * 10
  end
  
  def get_hash
    {:a => SampleClass.new, OtherClass.new(11) => "hello", :array => [SampleClass.new, SampleClass.new, 10]}
  end
  
  def another_method
    6.6
  end
  
  def hash
    @value
  end
  
  def ==(other)
    other.value == value
  end
end

class ActsAsWrappedCodeTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def test_wrappers_exist
    assert defined?(OtherClassWrapper)
    assert defined?(SampleClassWrapper)
  end
  
  def test_unwrappers_to_wrapper
    assert SampleClass.public_instance_methods.include?("to_wrapper")
    assert OtherClass.public_instance_methods.include?("to_wrapper")
  end
  
  def test_awrappers_clean
    assert_contents_same ["method_missing"] + allowed_methods, SampleClassWrapper.public_instance_methods
    assert_contents_same ["method_missing"] + allowed_methods, OtherClassWrapper.public_instance_methods
  end
  
  def test_wrappers_method_missing_clean
    wrap = SampleClass.new.to_wrapper
    wrap.other_method
    assert_raise(NameError) { wrap.unsafe_method }
    assert_raise(NameError) { wrap.method_missing :unsafe_method }
  end
  
  def test_class1_wrappers
    wrap = SampleClass.new.to_wrapper
    assert wrap.is_a?(SampleClassWrapper)
    assert wrap.other_method.is_a?(Float)
    assert_equal 5.5, wrap.other_method
    assert wrap.get_other_class.is_a?(OtherClassWrapper)
  end
  
  def test_hash_and_equals
    wrap1 = OtherClass.new(11).to_wrapper
    wrap2 = OtherClass.new(11).to_wrapper
    assert_equal wrap1.hash, wrap2.hash
    assert_equal wrap1, wrap2
  end
    
  
  def test_class2_wrappers
    wrap = OtherClass.new(10.0).to_wrapper
    assert wrap.is_a?(OtherClassWrapper)
    assert_equal 10.0, wrap.value
    assert_equal 6.6, wrap.another_method
    array = wrap.get_sample_classes
    array.each do |a|
      assert a.is_a?(SampleClassWrapper)
    end
    hash = wrap.get_hash
    assert hash[:a].is_a?(SampleClassWrapper)
    assert_contents_same hash[:array].collect{|v| v.class.name}, ["SampleClassWrapper", "SampleClassWrapper", "Fixnum"]
  end
  
  def test_wrapped_class?
    assert SampleClass.wrapped_class?    
    assert OtherClass.wrapped_class?    
    assert !NotWrappedClass.wrapped_class?    
  end
  
  def assert_contents_same(array1, array2)
    assert_equal array1.length, array2.length, "#{array1.inspect} != #{array2.inspect}"
    array1.each { |a| assert array2.include?(a), "#{array2.inspect} does not contain #{a.inspect}" }
  end
  
  def allowed_methods
    ["__id__", "__send__", "is_a?", "kind_of?", "class", "hash", "inspect", "==", "<=>", "===", "_wrapped_object"]
  end
end
