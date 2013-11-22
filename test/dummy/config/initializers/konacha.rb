if defined?(Konacha) 
  require 'capybara/poltergeist'
  Konacha.configure do |config| 
    config.spec_dir = "test/javascripts" 
    config.driver = :poltergeist 
    config.stylesheets  = %w(test)
  end
end