$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plush/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "Plush Select"
  s.version     = Plush::VERSION
  s.authors     = ["Peter Leppers"]
  s.email       = ["p.leppers@nedforce.nl"]
  s.homepage    = "http://github.com/jpleppers/plush"
  s.summary     = " A jQuery based select and option enhancer"
  s.description = "Plush Select "

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

end
