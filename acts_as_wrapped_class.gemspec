me: acts_as_wrapped_class
version: !ruby/object:Gem::Version 
  version: 1.0.2
platform: ruby
authors: 
- David Stevenson
autorequire: 
bindir: bin
cert_chain: []

date: 2009-04-06 00:00:00 -07:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: hoe
  type: :development
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 1.11.0
    version: 
description: "== FEATURES/PROBLEMS:  *  Wrappers do not dispatch const_missing yet, so constants are not accessible yet.  == SYNOPSIS:  class Something acts_as_wrapped_class :methods => [:safe_method] # SomethingWrapper is now defined  def safe_method  # allowed to access this method through SomethingWrapper Something.new end  def unsafe_method  # not allowed to access this method through SomethingWrapper end end"
email: david@flouri.sh 
executables: []

extensions: []

extra_rdoc_files: 
- History.ty 
  name: hoe
  type: :development
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 1.11.0
    version: 
description: "== FEATURES/PROBLEMS:  *  Wrappers do not dispatch const_missing e_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: wrapped-class
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: automatically generate wrapper classes which restrict access to methods and constants in the wrapped class
test_files: 
- test/test_acts_as_wrapped_class.rb

