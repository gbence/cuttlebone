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
  #s.required_ruby_version     = ">= 1.9.2"
  s.required_rubygems_version = ">= 1.3.7"

  s.add_runtime_dependency     "rack",     "~> 1.2.2"
  s.add_runtime_dependency     "json",     "~> 1.5.0"
  s.add_runtime_dependency     "xmpp4r",   "~> 0.5"

  s.add_development_dependency "bundler",  "~> 1.0.0"
  s.add_development_dependency "rspec",    "~> 2.6.0"
  s.add_development_dependency "i18n"
  s.add_development_dependency "cucumber", "~> 1.0.0"
  s.add_development_dependency "simplecov","~> 0.4.0"
  s.add_development_dependency "capybara", "~> 1.0.0"
  s.add_development_dependency "haml",     "~> 3.0.0"

  s.files            = `git ls-files`.split("\n")
  s.executables      = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.extra_rdoc_files = [ "README.md" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = 'lib'
end
