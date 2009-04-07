# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_wrapped_class}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Stevenson"]
  s.date = %q{2009-04-04}
  s.description = %q{ActsAsWrappedClass is a gem which easily creates proxy classes for use in the freaky-freaky-sandbox}
  s.email = %q{david@flouri.sh}
  s.files = ["README.txt", "History.txt"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dsboulder/acts_as_wrapped_cass}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{acts_as_wrapped_class}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      # s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
    else
      # s.add_dependency(%q<mime-types>, [">= 1.15"])
    end
  else
    # s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  end
end

