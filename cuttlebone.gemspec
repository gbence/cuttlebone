require File.expand_path("../lib/cuttlebone/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cuttlebone"
  s.version     = Cuttlebone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bence Golda"]
  s.email       = ["bence@golda.me"]
  s.homepage    = "http://github.com/gbence/cuttlebone"
  s.summary     = "cuttlebone-#{Cuttlebone::VERSION}"
  s.description = "Cuttlebone helps you creating shell-alike applications."

  s.rubyforge_project         = "cuttlebone"
  s.required_rubygems_version = ">= 1.3.7"

  s.add_runtime_dependency "activesupport", "~> 3.0.0"

  s.add_development_dependency "bundler",  "~> 1.0.0"
  s.add_development_dependency "rspec",    "~> 2.5.0"
  s.add_development_dependency "i18n"
  s.add_development_dependency "cucumber", "~> 0.10.0"
  s.add_development_dependency "rcov",     "~> 0.9.0"

  s.files            = `git ls-files`.split("\n")
  s.executables      = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.extra_rdoc_files = [ "README.md" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = 'lib'
end
