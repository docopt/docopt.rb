require File.expand_path("../../lib/docopt.rb", __FILE__)

doc = <<DOCOPT
Example of program with many options using docopt.

Usage:
  #{__FILE__} [-hvqrf NAME] [--exclude=PATTERNS]
                     [--select=ERRORS | --ignore=ERRORS] [--show-source]
                     [--statistics] [--count] [--benchmark] PATH...
  #{__FILE__} (--doctest | --testsuite=DIR)
  #{__FILE__} --version

Arguments:
  PATH  destination path

Options:
  -h --help            show this help message and exit
  --version            show version and exit
  -v --verbose         print status messages
  -q --quiet           report only file names
  -r --repeat          show all occurrences of the same error
  --exclude=PATTERNS   exclude files or directories which match these comma
                       separated patterns [default: .svn,CVS,.bzr,.hg,.git]
  -f NAME --file=NAME  when parsing directories, only check filenames matching
                       these comma separated patterns [default: *#{__FILE__}]
  --select=ERRORS      select errors and warnings (e.g. E,W6)
  --ignore=ERRORS      skip errors and warnings (e.g. E4,W)
  --show-source        show source code for each error
  --statistics         count errors and warnings
  --count              print total number of errors and warnings to standard
                       error and set exit code to 1 if total is not null
  --benchmark          measure processing speed
  --testsuite=DIR      run regression tests from dir
  --doctest            run doctest on myself


DOCOPT

begin
  require "pp"
  pp Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end