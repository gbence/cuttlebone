require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rubygems/package_task'

#require 'rake/packagetask'

begin
  require 'haml'
  require 'sass'
rescue LoadError
end

CUTTLEBONE_GEMSPEC = eval(File.read(File.expand_path('../cuttlebone.gemspec', __FILE__)))

desc 'Default: run specs'
task :default => 'spec'

if defined?(Haml) and defined?(Sass)
  task :gem => 'rack:compile'

  namespace :rack do
    desc 'Compiles HTML/CSS files.'
    task :compile do
      {
        'index.html.haml' => 'index.html',
        'error.html.haml' => 'error.html',
        'cuttlebone.sass' => 'stylesheets/cuttlebone.css'
      }.each_pair do |f,t|
        File.open(File.expand_path("../public/#{t}", __FILE__), 'w') do |tt|
          tt.write(
            (
              f =~ /\.haml$/ ?
              Haml::Engine.new(File.read(File.expand_path("../public/sources/#{f}",__FILE__)), :format => :html5, :ugly => true) :
              Sass::Engine.new(File.read(File.expand_path("../public/sources/#{f}",__FILE__)))
            ).render()
          )
        end
      end
    end
  end
end

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
end

task :spec => 'spec:progress'

desc 'Run all cucumber tests.'
Cucumber::Rake::Task.new do |t|
end

desc 'Generate documentation for cuttlebone.'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cuttlebone'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Gem::PackageTask.new(CUTTLEBONE_GEMSPEC) do |p|
  p.gem_spec = CUTTLEBONE_GEMSPEC
end
