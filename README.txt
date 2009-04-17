ActsAsWrappedClass
    by David Stevenson 
    http://flouri.sh

== DESCRIPTION:
  
ActsAsWrappedClass is designed to automatically generate a wrapper for an object that you don't want to be allowed to access certain methods in.  This is useful in cases where you want to sandbox what users' code can and can't do, by providing them access to the wrapper classes rather than the original classes.

== FEATURES/PROBLEMS:
  
*  Wrappers do not dispatch const_missing yet, so constants are not accessible yet.

== SYNOPSIS:

	class Something
	  acts_as_wrapped_class :methods => [:safe_method]
	  # SomethingWrapper is now defined
  
	  def safe_method  # allowed to access this method through SomethingWrapper
	    Something.new
	  end

	  def unsafe_method  # not allowed to access this method through SomethingWrapper
	  end
	end

	s = Something.new
	wrapper = s.to_wrapper
	wrapper.safe_method    # returns a new SomethingWrapper
	wrapper.unsafe_method  # raises an exception

== REQUIREMENTS:

* none

== INSTALL:

* sudo gem install acts_as_wrapped_class

== LICENSE:

(The MIT License)

Copyright (c) 2007 David Stevenson 

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
