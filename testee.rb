#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/lib/docopt.rb")

require 'json'

doc = $stdin.read

begin
  puts Docopt::docopt(doc).to_json
rescue Docopt::Exit => ex
  puts '"user-error"'
end
