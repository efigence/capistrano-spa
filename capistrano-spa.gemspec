# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "capistrano-spa"
  gem.version       = '0.0.1'
  gem.authors       = ["Jacek Grzybowski"]
  gem.email         = ["jacek213@gmail.com"]
  gem.description   = %q{Capistrano tasks for Single Page Apps deployment}
  gem.summary       = %q{Capistrano tasks for Single Page Apps deployment}
  gem.homepage      = "https://github.com/efigence/capistrano-spa"

  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '~> 3.1'
  gem.add_dependency 'capistrano-bundler', '~> 1.1'
end
