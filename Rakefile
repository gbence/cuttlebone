require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

require 'rake/packagetask'
require 'rake/gempackagetask'

CUTTLEBONE_GEMSPEC = eval(File.read(File.expand_path('../cuttlebone.gemspec', __FILE__)))

desc 'Default: run specs'
task :default => 'spec'

namespace :spec do
  desc 'Run all specs in spec directory (format=progress)'
  RSpec::Core::RakeTask.new(:progress) do |t|
    t.pattern = './spec/**/*_spec.rb'
    t.rspec_opts = ['--color', '--format=progress']
  end

  desc 'Run all specs in spec directory (format=documentation)'
  RSpec::Core::RakeTask.new(:documentation) do |t|
    t.pattern = './spec/**/*_spec.rb'
    t.rspec_opts = ['--color', '--format=documentation']
  end

  desc "Run specs with rcov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.pattern = './spec/**/*_spec.rb'
    t.rcov = true
    t.rcov_opts = ['--exclude', 'gems/,spec/,features/']
  end
end

task :spec => 'spec:progress'

desc 'Run all cucumber tests.'
Cucumber::Rake::Task.new do |t|
end

desc 'Generate documentation for the a4-core plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'A4::Core'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(CUTTLEBONE_GEMSPEC) do |p|
  p.gem_spec = CUTTLEBONE_GEMSPEC
end
