`docopt.rb` – command line option parser, that will make you smile
===============================================================================

This is the ruby port of [`docopt`](https://github.com/docopt/docopt),
the awesome option parser written originally in python.

> New in version 0.5.0:
>
> Repeatable flags and commands are counted if repeated (a-la ssh `-vvv`).
> Repeatable options with arguments are accumulated into list.

Isn't it awesome how `optparse` and `argparse` generate help messages
based on your code?!

*Hell no!*  You know what's awesome?  It's when the option parser *is* generated
based on the beautiful help message that you write yourself!  This way
you don't need to write this stupid repeatable parser-code, and instead can
write only the help message--*the way you want it*.

`docopt` helps you create most beautiful command-line interfaces *easily*:

```ruby
require "docopt"
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
```

Beat that! The option parser is generated based on the docstring above that is
passed to `docopt` function.  `docopt` parses the usage pattern
(`Usage: ...`) and option descriptions (lines starting with dash "`-`") and
ensures that the program invocation matches the usage pattern; it parses
options, arguments and commands based on that. The basic idea is that
*a good help message has all necessary information in it to make a parser*.

Installation
===============================================================================

Docopt is available via rubygems:

    gem install docopt

Alternatively, you can just drop `lib/docopt.rb` file into your project--it is
self-contained. [Get source on github](http://github.com/docopt/docopt.rb).

`docopt` has been confirmed to work with 1.8.7p370 and 1.9.3p194. If you have
noticed it working (or not working) with an earlier version, please raise an
issue and we will investigate support.

API
===============================================================================

`Docopt` takes 1 required and 1 optional argument:

- `doc` should be a string that
describes **options** in a human-readable format, that will be parsed to create
the option parser.  The simple rules of how to write such a docstring
(in order to generate option parser from it successfully) are given in the next
section. Here is a quick example of such a string:

        Usage: your_program.rb [options]

        -h --help     Show this.
        -v --verbose  Print more text.
        --quiet       Print less text.
        -o FILE       Specify output file [default: ./test.txt].


The optional second argument contains a hash of additional data to influence
docopt. The following keys are supported: 

- `help`, by default `true`, specifies whether the parser should automatically
print the usage-message (supplied as `doc`) in case `-h` or `--help` options
are encountered. After showing the usage-message, the program will terminate.
If you want to handle `-h` or `--help` options manually (as all other options),
set `help=false`.

- `version`, by default `nil`, is an optional argument that specifies the
version of your program. If supplied, then, if the parser encounters
`--version` option, it will print the supplied version and terminate.
`version` could be any printable object, but most likely a string,
e.g. `'2.1.0rc1'`.

Note, when `docopt` is set to automatically handle `-h`, `--help` and
`--version` options, you still need to mention them in the options description
(`doc`) for your users to know about them.

The **return** value is just a dictionary with options, arguments and commands,
with keys spelled exactly like in a help message
(long versions of options are given priority). For example, if you invoke
the top example as::

    naval_fate.rb ship Guardian move 100 150 --speed=15

the return dictionary will be::

```ruby
{"ship"=>true,
 "new"=>false,
 "<name>"=>["Guardian"],
 "move"=>true,
 "<x>"=>"100",
 "<y>"=>"150",
 "--speed"=>"15",
 "shoot"=>false,
 "mine"=>false,
 "set"=>false,
 "remove"=>false,
 "--moored"=>false,
 "--drifting"=>false,
 "--help"=>false,
 "--version"=>false}
```

Help message format
===============================================================================

docopt.rb follows the docopt help message format.
You can find more details at
[official docopt git repo](https://github.com/docopt/docopt#help-message-format)


Examples
-------------------------------------------------------------------------------

We have an extensive list of
[examples](https://github.com/docopt/docopt.rb/tree/master/examples)
which cover every aspect of functionality of `docopt`.  Try them out,
read the source if in doubt.

Data validation
-------------------------------------------------------------------------------

`docopt` does one thing and does it well: it implements your command-line
interface.  However it does not validate the input data.  We are looking
for ruby validation libraries to make your option parsing experiene
even more awesome!
If you've got any suggestions or think your awesome schema validation gem
fits well with `docopt.rb`, open an issue on github and enjoy the eternal glory!

Contribution
===============================================================================

We would *love* to hear what you think about `docopt.rb`.
Contribute, make pull requrests, report bugs, suggest ideas and discuss
`docopt.rb` on
[issues page](http://github.com/docopt/docopt.rb/issues).

If you want to discuss the original `docopt` reference,
point to [it's home](http://github.com/docopt/docopt) or
drop a line directly to vladimir@keleshev.com!

Porting `docopt` to other languages
===============================================================================

Docopt is an interlinguistic (?) effort,
and this is the ruby port of `docopt`.
We coordinate our efforts with docopt community and try our best to
keep in sync with the python reference.

Docopt community *loves* to hear what you think about `docopt`, `docopt.rb`
and other sister projects on docopt's
[issues page](http://github.com/docopt/docopt/issues).