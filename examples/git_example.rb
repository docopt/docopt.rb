require File.expand_path("../../lib/docopt.rb", __FILE__)

doc = <<DOCOPT
Usage:
    #{__FILE__} remote [-v | --verbose]
    #{__FILE__} remote add [-t <branch>] [-m <master>] [-f]
                   [--tags|--no-tags] [--mirror] <name> <url>
    #{__FILE__} remote rename <old> <new>
    #{__FILE__} remote rm <name>
    #{__FILE__} remote set-head <name> (-a | -d | <branch>)
    #{__FILE__} remote set-branches <name> [--add] <branch>...
    #{__FILE__} remote set-url [--push] <name> <newurl> [<oldurl>]
    #{__FILE__} remote set-url --add [--push] <name> <newurl>
    #{__FILE__} remote set-url --delete [--push] <name> <url>
    #{__FILE__} remote [-v | --verbose] show [-n] <name>
    #{__FILE__} remote prune [-n | --dry-run] <name>
    #{__FILE__} remote [-v | --verbose] update [-p | --prune]
                   [(<group> | <remote>)...]

Options:
    -v, --verbose
    -t <branch>
    -m <master>
    -f
    --tags
    --no-tags
    --mittor
    -a
    -d
    -n, --dry-run
    -p, --prune
    --add
    --delete
    --push
    --mirror

DOCOPT

begin
  require "pp"
  pp Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end