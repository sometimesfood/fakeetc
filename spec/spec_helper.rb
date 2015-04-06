if ENV['CODECLIMATE_REPO_TOKEN=']
  require 'simplecov'
  require 'codeclimate-test-reporter'
  ignored_directories = %w(/spec/ /vendor/ /.bundle/)
  formatters = [SimpleCov::Formatter::HTMLFormatter,
                CodeClimate::TestReporter::Formatter]
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  SimpleCov.start { ignored_directories.each { |dir| add_filter(dir) } }
end

require 'minitest/autorun'
