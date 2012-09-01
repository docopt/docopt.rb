require File.expand_path("../../lib/docopt.rb", __FILE__)

#The *popular* naval fate example

doc = <<DOCOPT
Naval Fate.

Usage:
  #{__FILE__} ship new <name>...
  #{__FILE__} ship <name> move <x> <y> [--speed=<kn>]
  #{__FILE__} ship shoot <x> <y>
  #{__FILE__} mine (set|remove) <x> <y> [--moored|--drifting]
  #{__FILE__} -h | --help
  #{__FILE__} --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.

DOCOPT

begin
  require "pp"
  pp Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end