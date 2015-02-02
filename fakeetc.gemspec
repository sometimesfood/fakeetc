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

  gem.files         = Dir['Rakefile',
                          'README.md',
                          'LICENSE',
                          'NEWS',
                          '{bin,lib,man,spec}/**/*'] \
                        & `git ls-files -z`.split("\0")

  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.name          = 'fakeetc'
  gem.require_paths = ['lib']
  gem.version       = FakeEtc::VERSION

  gem.add_development_dependency 'rake', '~> 10.4.2'
  gem.add_development_dependency 'minitest', '~> 5.5.1'
end
