# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metaimg/version'

Gem::Specification.new do |spec|
  spec.name          = "metaimg"
  spec.version       = Metaimg::VERSION
  spec.authors       = ["Kensuke Sawada"]
  spec.email         = ["sasasawada@gmail.com"]
  spec.summary       = %q{The simple image viewer.}
  spec.homepage      = "https://github.com/sawaken/metaimg"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sinatra"
  spec.add_dependency "thin"
  spec.add_dependency "rmagick"
  spec.add_dependency "sqlite3"
  spec.add_dependency "sequel"
end
