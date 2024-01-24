# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tlopo/request'
require 'simplecov'
require 'minitest/autorun'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter
                                                               ])

# Use simplecov with forking specs
pid = Process.pid
SimpleCov.at_exit do
  SimpleCov.result.format! if Process.pid == pid
end

SimpleCov.minimum_coverage 80
SimpleCov.start
