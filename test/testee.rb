#!/usr/bin/env ruby
require File.expand_path("../../lib/docopt.rb", __FILE__)

require 'json'

doc = STDIN.read

begin
  puts Docopt::docopt(doc).to_json
rescue Docopt::Exit => ex
  puts '"user-error"'
end
