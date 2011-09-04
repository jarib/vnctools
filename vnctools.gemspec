# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "vnctools/version"

Gem::Specification.new do |s|
  s.name        = "vnctools"
  s.version     = VncTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Simple CLI wrappers to control and record VNC displays from Ruby.}
  s.description = %q{Simple CLI wrappers to control and record VNC displays from Ruby.}

  s.rubyforge_project = "vnctools"

  s.add_dependency "childprocess"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rspec", "~> 2.5"
  s.add_development_dependency "rake", "~> 0.9.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
