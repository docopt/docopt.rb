`docopt` – command line option parser, that will make you smile
===============================================================================

Isn't it awesome how `optparse` and `argparse` generate help messages
based on your code?!

*Hell no!*  You know what's awesome?  It's when the option parser *is* generated
based on the beautiful help message that you write yourself!  This way
you don't need to write this stupid repeatable parser-code, and instead can
write only the help message--*the way you want it*.

`docopt` helps you create most beautiful command-line interfaces *easily*:

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
    options = Docopt(doc, {:version => '1.0.0'})
    puts options.inspect
    puts ARGV.inspect
end
```

Beat that! The option parser is generated based on the docstring above that is
passed to `docopt` function.  `docopt` parses the usage pattern
(`"Usage: ..."`) and option descriptions (lines starting with dash "`-`") and
ensures that the program invocation matches the usage pattern; it parses
options, arguments and commands based on that. The basic idea is that
*a good help message has all necessary information in it to make a parser*.

```ruby
require 'docopt'
doc = "Usage: your_program.rb [options]

  -h --help     Show this.
  -v --verbose  Print more text.
  --quiet       Print less text.
  -o FILE       Specify output file [default: ./test.txt]"

options = Docopt(doc, { :version => nil, :help => true })`

options['--help'] # returns true or false depending on option given

```


Installation
===============================================================================

~~Docopt is available through rubygems:~~

    gem install docopt

*Please note: the gem provides an out of date version. We are working on getting
it updated.*

Alternatively, you can just drop `docopt.rb` file into your project--it is
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

    naval_fate.py ship Guardian move 100 150 --speed=15

the return dictionary will be::

```python
{'--drifting' => False,    'mine' => False,
 '--help' => False,        'move' => True,
 '--moored' => False,      'new' => False,
 '--speed' => '15',        'remove' => False,
 '--version' => False,     'set' => False,
 '<name>' => ['Guardian'], 'ship' => True,
 '<x>' => '100',           'shoot' => False,
 '<y>' => '150'}
```

Help message format
===============================================================================

Help message consists of 2 parts:

- Usage pattern, e.g.::

        Usage: my_program.py [-hso FILE] [--quiet | --verbose] [INPUT ...]

- Option descriptions, e.g.::

        -h --help    show this
        -s --sorted  sorted output
        -o FILE      specify output file [default: ./test.txt]
        --quiet      print less text
        --verbose    print more text

Their format is described below; other text is ignored.
Also, take a look at the
[beautiful examples](https://github.com/docopt/docopt/tree/master/examples>).

Usage pattern format
-------------------------------------------------------------------------------

**Usage pattern** is a substring of `doc` that starts with
`usage:` (case-*in*sensitive) and ends with a *visibly* empty line.
Minimum example::

```python
"""Usage: my_program.py

"""
```

The first word after `usage:` is interpreted as your program's name.
You can specify your program's name several times to signify several
exclusive patterns::

```python
"""Usage: my_program.py FILE
          my_program.py COUNT FILE

"""
```

Each pattern can consist of the following elements:

- **<arguments>**, **ARGUMENTS**. Arguments are specified as either
  upper-case words, e.g.
  `my_program.py CONTENT-PATH`
  or words surrounded by angular brackets:
  `my_program.py <content-path>`.
- **--options**.
  Options are words started with dash (`-`), e.g. `--output`, `-o`.
  You can "stack" several of one-letter options, e.g. `-oiv` which will
  be the same as `-o -i -v`. The options can have arguments, e.g.
  `--input=FILE` or
  `-i FILE` or even `-iFILE`. However it is important that you specify
  option descriptions if you want for option to have an argument, a
  default value, or specify synonymous short/long versions of option
  (see next section on option descriptions).
- **commands** are words that do *not* follow the described above conventions
  of `--options` or `<arguments>` or `ARGUMENTS`, plus two special
  commands: dash "`-`" and double dash "`--`" (see below).

Use the following constructs to specify patterns:

- **[ ]** (brackets) **optional** elements.
  e.g.: `my_program.py [-hvqo FILE]`
- **( )** (parens) **required** elements.
  All elements that are *not* put in **[ ]** are also required,
  e.g.: `my_program.py --path=<path> <file>...` is the same as
  `my_program.py (--path=<path> <file>...)`.
  (Note, "required options" might be not a good idea for your users).
- **|** (pipe) **mutualy exclussive** elements. Group them using **( )** if
  one of the mutually exclussive elements is required:
  `my_program.py (--clockwise | --counter-clockwise) TIME`. Group them using
  **[ ]** if none of the mutually-exclusive elements are required:
  `my_program.py [--left | --right]`.
- **...** (ellipsis) **one or more** elements. To specify that arbitrary
  number of repeating elements could be accepted, use ellipsis (`...`), e.g.
  `my_program.py FILE ...` means one or more `FILE`-s are accepted.
  If you want to accept zero or more elements, use brackets, e.g.:
  `my_program.py [FILE ...]`. Ellipsis works as a unary operator on the
  expression to the left.
- **[options]** (case sensitive) shortcut for any options.
  You can use it if you want to specify that the usage
  pattern could be provided with any options defined below in the
  option-descriptions and do not want to enumerate them all in pattern.
- "`[--]`". Double dash "`--`" is used by convention to separate
  positional arguments that can be mistaken for options. In order to
  support this convention add "`[--]`" to you usage patterns.
- "`[-]`". Single dash "`-`" is used by convention to signify that
  `stdin` is used instead of a file. To support this add "`[-]`" to
  you usage patterns. "`-`" act as a normal command.

If your pattern allows to match argument-less option (a flag) several times:

    Usage: my_program.py [-v | -vv | -vvv]

then number of occurences of the option will be counted. I.e. `args['-v']`
will be `2` if program was invoked as `my_program -vv`. Same works for
commands.

If your usage patterns allows to match same-named option with argument
or positional argument several times, the matched arguments will be
collected into a list:

    Usage: my_program.py <file> <file> --path=<path>...

I.e. invoked with `my_program.py file1 file2 --path=./here --path=./there`
the returned dict will contain `args['<file>'] == ['file1', 'file2']` and
`args['--path'] == ['./here', './there']`.


Option descriptions format
-------------------------------------------------------------------------------

**Option descriptions** consist of a list of options that you put below your
usage patterns.

It is necessary to list option descriptions in order to specify:

- synonymous short and long options,
- if an option has an argument,
- if option's argument has a default value.

The rules are as follows:

- Every line in `doc` that starts with `-` or `--` (not counting spaces)
  is treated as an option description, e.g.:

        Options:
          --verbose   # GOOD
          -o FILE     # GOOD
        Other: --bad  # BAD, line does not start with dash "-"

- To specify that option has an argument, put a word describing that
  argument after space (or equals "`=`" sign) as shown below. Follow
  either <angular-brackets> or UPPER-CASE convention for options' arguments.
  You can use comma if you want to separate options. In the example below, both
  lines are valid, however you are recommended to stick to a single style. :

        -o FILE --output=FILE       # without comma, with "=" sign
        -i <file>, --input <file>   # with comma, wihtout "=" sing

- Use two spaces to separate options with their informal description.

        --verbose More text.   # BAD, will be treated as if verbose option had
                               # an argument "More", so use 2 spaces instead
        -q        Quit.        # GOOD
        -o FILE   Output file. # GOOD
        --stdout  Use stdout.  # GOOD, 2 spaces

- If you want to set a default value for an option with an argument, put it
  into the option-description, in form `[default: <my-default-value>]`.

        --coefficient=K  The K coefficient [default: 2.95]
        --output=FILE    Output file [default: test.txt]
        --directory=DIR  Some directory [default: ./]

