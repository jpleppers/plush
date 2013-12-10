begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Plush'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# load_app is defined and invoked in engine.rake, below
# we have to sneak in our additions so konacha is loaded.
task 'load_app' do
  require 'action_controller/railtie'
  require 'konacha'
  load 'tasks/konacha.rake'

  module Konacha
    def self.spec_root
      Plush::Engine.config.root + config.spec_dir
    end
  end

  class Konacha::Engine
    initializer "konacha.engine.environment", after: "konacha.environment" do
      # Rails.application is the dummy app in test/dummy
      Rails.application.config.assets.paths << Plush::Engine.config.root + Konacha.config.spec_dir
    end
  end
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task default: :test
