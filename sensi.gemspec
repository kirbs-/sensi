# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sensi/version'

Gem::Specification.new do |spec|
  spec.name          = "sensi"
  spec.version       = Sensi::VERSION
  spec.authors       = ["Chris Kirby"]
  spec.email         = ["kirbycm@gmail.com"]

  spec.summary       = %q{Emmerson Sensi thermostat API wrapper.}
  spec.description   = %q{Emmerson Sensi thermostat API wrapper.}
  spec.homepage      = "https://github.com/kirbs-/sensi"
  spec.license       = "GNU General Public License v2.0"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', "~> 0.13"
  spec.add_dependency 'json', "~> 1.8"
  spec.add_dependency 'curb', "~> 0.7"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
