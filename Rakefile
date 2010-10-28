require 'rake'
require 'rake/clean'
CLEAN.include %w(**/*.{log,rbc})

require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "socky-client"
    gemspec.summary = "Socky is a WebSocket server and client for Ruby"
    gemspec.description = "Socky is a WebSocket server and client for Ruby"
    gemspec.email = "bernard.potocki@imanel.org"
    gemspec.homepage = "http://imanel.org/projects/socky"
    gemspec.authors = ["Bernard Potocki"]
    gemspec.add_dependency 'json'
    gemspec.add_development_dependency 'rspec', '~> 2.0'
    gemspec.files.exclude ".gitignore"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
