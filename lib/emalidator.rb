require 'emalidator/version'
require 'emalidator/main'
require 'emalidator/email'
require 'emalidator'

require 'awesome_print'
require 'benchmark'
require 'byebug'
require 'csv'
require 'json'
require 'net/smtp/proxy'
# require 'net/smtp'
require 'parallel'
require 'resolv'
# require 'resolv-replace'
require 'thor'

module Emalidator
  class CLI < Thor
    desc 'validate path/to/file|email', 'Validates emails from a file or inline email'
    def validate(main_arg)
      Emalidator::Main.new main_arg: main_arg
    end
  end
end
