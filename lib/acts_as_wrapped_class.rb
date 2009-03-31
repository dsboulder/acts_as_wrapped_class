require "erb"

module ActsAsWrappedClass
  VERSION = "1.0.1"
  WRAPPED_CLASSES = []
  
  module InstanceMethods
    def to_wrapper
      eval("#{self.class.name}Wrapper").new(self)
    end
  end
  
  module ClassMethods
    def wrapped_class?
      true
    end
  end
  
  class WrapperFinder
    SANDBOX_BASE_IMPORTS = ["Object", "Module", "Class", "Kernel", "Main", "Array", "Bignum", "Binding", "Comparable", "Cont", "Data", "Dir", "Enumerable", "Exception", "FalseClass", "FConst", "File", "FileTest", "Fixnum", "Float", "GC", "Hash", "Integer", "IO", "Marshal", "Math", "Match", "Method", "NilClass", "Numeric", "ObSpace", "Precision", "Proc", "Process", "ProcStatus", "ProcUID", "ProcGID", "ProcID_Syscall", "Range", "Regexp", "Stat", "String", "Struct", "Symbol", "Thread", "ThGroup", "Time", "Tms", "TrueClass", "UnboundMethod", "StandardError", "SystemExit", "Interrupt", "Signal", "Fatal", "ArgError", "EOFError", "IndexError", "RangeError", "RegexpError", "IOError", "RuntimeError", "SecurityError", "SystemCallError", "SysStackError", "ThreadError", "TypeError", "ZeroDivError", "NotImpError", "NoMemError", "NoMethodError", "FloatDomainError", "ScriptError", "NameError", "NameErrorMesg", "SyntaxError", "LoadError", "LocalJumpError", "Errno", "BoxedClass"]
    @@special_handlers = {Array => Proc.new{ |object| object.collect{|val| find_wrapper_for(val)} },
      Hash => Proc.new{ |object| object.inject({}){|h, key_val| h[find_wrapper_for(key_val[0])] = find_wrapper_for(key_val[1]); h } }}
    
    # Returns a wrapper for an instance of an object, if one exsits, or the original object if it's a core datatype.
    # * This will first attempt to find a special handler for the type of object being wrapped and invoke it's block
    # * Then it will look for a wrapper classes that fits the object's type (Something looks for SomethingWrapper)
    # * Finally, it checks a list of "safe" classes that don't need wrapping
    # If no match is found, an exception is raised
    def self.find_wrapper_for(object)
      wrapper_name = "#{object.class.name}Wrapper"
      return nil if nil
      
      @@special_handlers.each do |key, value|
        return value.call(object) if object.is_a?(key)
      end            

      return object if object.kind_of?(WrapperBase)
      return eval(wrapper_name).new(object) if eval("defined?(#{wrapper_name})")
      return object if SANDBOX_BASE_IMPORTS.include?(object.class.name)

      raise "Can't find wrapper for class: #{object.class.name}"
    end
    
    # Add a special handler for how to wrap certain types of classes.
    # For example, if you wanted to wrap Arrays by wrapping each of their elements
    def self.add_special_handler(klass, prc)
      raise "1st arg must be a Class" unless klass.is_a?(Class)
      raise "2st arg must be a Proc" unless prc.is_a?(Proc)
      @@special_handlers[klass] = prc
    end
  end
  
  def wrapped_class?
    false
  end
  
  # Mark a class as wrapped, creating a wrapper class which allows access to certain methods specified by EITHER the :methods safe list of the :except_methods blacklist.  
  # You cannot use both :methods and :except_methods at once.
  # * options[:methods] contains a list of method names (symbols) to allow access to
  # * options[:except_methods] contains a list of method names (symbols) to not allow access to
  # * options[:constants] contains a list of constant names (symbols) to allow access to
  # * options[:except_constants] contains a list of constant names (symbols) to not allow access to
  def acts_as_wrapped_class(options = {})
    
    raise "Can't specify methods to allow and to deny." if options[:methods] && options[:except_methods]
    raise "Can't specify constants to allow and to deny." if options[:constants] && options[:except_constants]
    options[:methods] ||= :all unless options[:except_methods]
    options[:constants] ||= :all unless options[:except_constants]
    
    WRAPPED_CLASSES << self
    
    if options[:methods] == :all
      options.delete(:methods)
      options[:except_methods] = []
    end

    if options[:constants] == :all
      options.delete(:constants)
      options[:except_constants] = []
    end    
    
    meths = options[:methods] || options[:except_methods]
    consts = options[:constants] || options[:except_constants]
    
    allowed_method_missing = options[:methods] ? options[:methods].include?(:method_missing) : !options[:except_methods].include?(:method_missing)
    allowed_const_missing = options[:constants] ? options[:constants].include?(:cont_missing) : !options[:except_constants].include?(:const_missing)

    self.send(:include, ActsAsWrappedClass::InstanceMethods)
    self.send(:extend, ActsAsWrappedClass::ClassMethods)
    
    if allowed_method_missing
      method_defs_erb = <<-EOF
        def method_missing(meth, *args);
          <% if options[:except_methods] %>
            raise NameError.new("Method `"+meth.to_s+"' now allowed") if [<%= meths.collect {|m| ":\#{m}"}.join(", ") %>].include?(meth)
          <% else %>
            raise NameError.new("Method `"+meth.to_s+"' now allowed") unless [<%= meths.collect {|m| ":\#{m}"}.join(", ") %>].include?(meth) || !@wrapped_object.class.method_defined?(meth)
          <% end %>
          ActsAsWrappedClass::WrapperFinder.find_wrapper_for(@wrapped_object.send(meth, *args));
        end
        EOF
    else      
      method_defs_erb = <<-EOF
        def method_missing(meth, *args);
          raise NameError.new("Method `"+meth.to_s+"' now allowed") <%= options[:methods] ? "unless" : "if"%> [<%=meths.collect {|m| ":\#{m}"}.join(", ")%>].include?(meth)
          ActsAsWrappedClass::WrapperFinder.find_wrapper_for(@wrapped_object.method(meth).call(*args));
        end
        EOF
    end
    
    # if allowed_const_missing
    #   const_defs_erb = <<-EOF
    #     def const_missing(const, *args);
    #       <% if options[:except_constants] %>
    #         raise NameError.new("Constant `"+const.to_s+"' now allowed") if [<%= consts.collect {|c| ":\#{c}"}.join(", ") %>].include?(const)
    #       <% else %>
    #         raise NameError.new("Method `"+meth.to_s+"' now allowed") unless [<%= meths.collect {|c| ":\#{c}"}.join(", ") %>].include?(const) || !@wrapped_object.class.const_defined?(const)
    #       <% end %>
    #       @wrapped_object.const_get(const)
    #     end
    #     EOF
    # else      
    #   const_defs_erb = <<-EOF
    #     def const_missing(const, *args);
    #       raise NameError.new("Constant `"+const.to_s+"' now allowed") <%= options[:constants] ? "unless" : "if"%> [<%=consts.collect {|m| ":\#{m}"}.join(", ")%>].include?(const)
    #       @wrapped_object.const_get(const)
    #     end
    #     EOF
    # end
    
    method_defs = ERB.new(method_defs_erb).result(binding)
    
    allowed_methods = <<-EOF
      def self.allowed_methods
          #{ options[:except_methods] ? 
                ("#{self.name}.public_instance_methods - [" + (meths + WrapperBase::ALLOWED_METHODS + ["to_wrapper"]).collect{|m| "\"#{m}\"" }.join(", ") + "]") :
                ("[" + meths.collect{|m| "\"#{m}\""}.join(", ") + "]")
            }
      end
    EOF
        
    wrapper_class_code = <<-EOF
      class #{self.name}Wrapper < WrapperBase
        #{method_defs}
        #{allowed_methods}
      end
    EOF

    eval wrapper_class_code, TOPLEVEL_BINDING
  end
end

Object.send(:include, ActsAsWrappedClass)

require File.join(File.dirname(__FILE__), "wrapper_base")
