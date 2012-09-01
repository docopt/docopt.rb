require File.expand_path("../../lib/docopt.rb", __FILE__)

doc = <<DOCOPT
Example of program which uses [options] shortcut in pattern.

Usage:
  #{__FILE__} [options] <port>

Options:
  -h --help                show this help message and exit
  --version                show version and exit
  -n, --number N           use N as a number
  -t, --timeout TIMEOUT    set timeout TIMEOUT seconds
  --apply                  apply changes to database
  -q                       operate in quiet mode

DOCOPT


begin
  puts Docopt::docopt(doc, version: '1.0.0rc2').to_s
rescue Docopt::Exit => e
  puts e.message
end
