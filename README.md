`docopt` – command line option parser, that will make you smile
===============================================================================

Help porting [docopt](http://docopt.org/) to Ruby!

Isn't it awesome how `optparse` and other option parsers generate help and
usage-messages based on your code?!

Hell no!  You know what's awesome?  It's when the option parser *is* generated
based on the help and usage-message that you write in a docstring!  This way
you don't need to write this stupid repeatable parser-code, and instead can
write a beautiful usage-message (the way you want it!), which adds readability
to your code.

Now you can write an awesome, readable, clean, DRY code like *that*:

```ruby
doc = "Usage: example.rb [options] <arguments>...

Options:
  -h --help            show this help message and exit
  --version            show version and exit
  -v --verbose         print status messages
  -q --quiet           report only file names
  -r --repeat          show all occurrences of the same error
  --exclude=patterns   exclude files or directories which match these comma
                       separated patterns [default: .svn,CVS,.bzr,.hg,.git]
  --filename=patterns  when parsing directories, only check filenames matching
                       these comma separated patterns [default: *.rb]
  --select=errors      select errors and warnings (e.g. E,W6)
  --ignore=errors      skip errors and warnings (e.g. E4,W)
  --show-source        show source code for each error
  --statistics         count errors and warnings
  --count              print total number of errors and warnings to standard
                       error and set exit code to 1 if total is not null
  --benchmark          measure processing speed
  --testsuite=dir      run regression tests from dir
  --doctest            run doctest on myself"

require 'docopt'


if __FILE__ == $0
    options = Docopt(doc, '1.0.0')  # parse options based on doc above
    puts options.inspect
    puts ARGV.inspect
end
```

Hell yeah! The option parser is generated based on `doc` string above, that you
pass to the `Docopt` function.

API `require 'docopt'`
===============================================================================

###`options = Docopt(doc, version=nil, help=true)`

`Docopt` takes 1 required and 2 optional arguments:

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

The **return** value is an instance of the ```Docopt``` class:

```ruby
doc = "Options:
  --verbose
  -o FILE  Output file [default: out.txt]"
  
options = Docopt(doc)

puts options.inspect
# --verbose=nil
# -o="out.txt"
```

You can access the values of options like a hash:

```
doc = "Options:
  -v, --verbose  Verbose output [default: true]
  -o FILE  Output file [default: out.txt]"
  
options = Docopt(doc)

# The following are equivilant:

puts options['-v']
puts options['--verbose']
puts options[:v]
puts options[:verbose]


```

You can access positional arguments in `ARGV`.

`doc` string format for your usage-message
===============================================================================

The main idea behind `docopt` is that a good usage-message (that describes
options and defaults unambiguously) is enough to generate an option parser.

Here are the simple rules (that you probably already follow) for your
usage-message to be parsable:

- Every line that starts with `-` or `--` (not counting spaces) is treated
as an option description, e.g.:

        Options:
          --verbose   # GOOD
          -o FILE     # GOOD
        Other: --bad  # BAD, line does not start with dash "-"

- To specify that an option has an argument, put a word describing that
argument after space (or equals `=` sign) as shown below.
You can use comma if you want to separate options. In the example below both
lines are valid, however you are recommended to stick to a single style.

        -o FILE --output=FILE       # without comma, with "=" sign
        -i <file>, --input <file>   # with comma, wihtout "=" sing

- Use two spaces to separate options with their informal description.

        --verbose More text.   # BAD, will be treated as if verbose option had
                               # an argument "More", so use 2 spaces instead
        -q        Quit.        # GOOD
        -o FILE   Output file. # GOOD
        --stdout  Use stdout.  # GOOD, 2 spaces

- If you want to set a default value for an option with an argument, put it
into the option description, in form `[default: <my-default-value>]`.

        -i INSTANCE      Instance of something [default: 1]
        --coefficient=K  The K coefficient [default: 2.95]
        --output=FILE    Output file [default: test.txt]
        --directory=DIR  Some directory [default: ./]

Something missing? Help porting [docopt](http://docopt.org/) to Ruby!
===============================================================================

Compatibility notice:
===============================================================================

In order to maintain your program's compatibility with future versions
of `docopt.rb` (as porting more features continues) you are recommended to
keep the following in the begining of `doc` argument:

    Usage: my_program.rb [options] <arguments>...

or

    Usage: my_program.rb [options] <argument>

or

    Usage: my_program.rb [options]

(followed by an empty line), where you are free to change `my_program.rb`
and `argument(s)` name inside of `<...>`.
