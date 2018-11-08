require 'emalidator/version'
require 'emalidator/emalidator'
require 'emalidator/email'
require 'emalidator'

require 'awesome_print'
require 'benchmark'
require 'byebug'
require 'csv'
require 'json'
require 'resolv-replace'
require 'net/smtp'
require 'parallel'
require 'resolv'
require 'thor'

module Emalidator
  class CLI < Thor
    desc 'validate path/to/file|email', 'Validates emails from a file or inline email'
    def validate(main_arg)
      Emalidator::Emalidator::Emalidator.new main_arg: main_arg
    end
  end
end
