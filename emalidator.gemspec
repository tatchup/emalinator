# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emalidator/version'

Gem::Specification.new do |spec|
  spec.name          = "emalidator"
  spec.version       = Emalidator::VERSION
  spec.authors       = ["Pedro Bernardes"]
  spec.email         = ["phec06@gmail.com"]

  spec.summary       = %q{A command line tool to validate emails}
  spec.description   = %q{A command line tool to validate emails}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'awesome_print', '~> 1.8'

  spec.add_dependency 'thor', '~> 0.20'
  spec.add_dependency 'csv', '~> 3.0'
  spec.add_dependency 'parallel', '~> 1.12'
  spec.add_dependency 'net-smtp-proxy', '~> 2.0'
end
