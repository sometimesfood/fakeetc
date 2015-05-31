require File.expand_path('../lib/fakeetc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Sebastian Boehm']
  gem.email         = ['sebastian@sometimesfood.org']
  gem.license       = 'MIT'
  gem.summary       = 'A fake Etc module for your tests'
  gem.homepage      = 'https://github.com/sometimesfood/fakeetc'
  gem.description   = <<EOS
FakeEtc is a fake Etc module for your tests.
EOS

  gem.files         = Dir['{bin,lib,man,spec}/**/*',
                          'Rakefile',
                          'README.md',
                          'NEWS.md',
                          'LICENSE'] & `git ls-files -z`.split("\0")

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'fakeetc'
  gem.require_paths = ['lib']
  gem.version       = FakeEtc::VERSION

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_development_dependency 'rake', '~> 10.4.2'
  gem.add_development_dependency 'minitest', '~> 5.6.0'
  gem.add_development_dependency 'yard', '~> 0.8.7.6'
end
