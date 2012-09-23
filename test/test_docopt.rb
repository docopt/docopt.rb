$:.unshift File.expand_path('../../lib', __FILE__)

require 'docopt'
require 'shellwords'
require 'set'
require 'test/unit'


class DocoptTest < Test::Unit::TestCase
  include Docopt

  %w[Argument Option Required OneOrMore Optional Either Command].each do |meth_constructor|
    class_eval <<-EOS
      def #{meth_constructor}(*args)
        ::Docopt::#{meth_constructor}.new(*args)
      end
    EOS
  end
  def docopt(doc, argv = nil)
    Docopt.docopt(doc, argv: (argv && argv.shellsplit))
  end
  %w[printable_usage  formal_usage  parse_doc_options  extras  dump_patterns  parse_argv  parse_atom  parse_seq  parse_expr  parse_pattern  parse_shorts  parse_long].each do |class_meth|
    class_eval <<-EOS
      def #{class_meth}(*args)
        Docopt.#{class_meth}(*args)
      end
    EOS

  end

  def test_pattern_flat
    assert_equal [Argument('N'), Option('-a'), Argument('M')],
                  Required(OneOrMore(Argument('N')), Option('-a'), Argument('M')).flat
  end

  def test_option
    assert Option.parse('-h') == Option('-h', nil)
    assert Option.parse('--help') == Option(nil, '--help')
    assert Option.parse('-h --help') == Option('-h', '--help')
    assert Option.parse('-h, --help') == Option('-h', '--help')

    assert Option.parse('-h TOPIC') == Option('-h', nil, 1)
    assert Option.parse('--help TOPIC') == Option(nil, '--help', 1)
    assert Option.parse('-h TOPIC --help TOPIC') == Option('-h', '--help', 1)
    assert Option.parse('-h TOPIC, --help TOPIC') == Option('-h', '--help', 1)
    assert Option.parse('-h TOPIC, --help=TOPIC') == Option('-h', '--help', 1)

    assert Option.parse('-h  Description...') == Option('-h', nil)
    assert Option.parse('-h --help  Description...') == Option('-h', '--help')
    assert Option.parse('-h TOPIC  Description...') == Option('-h', nil, 1)

    assert Option.parse('    -h') == Option('-h', nil)

    assert Option.parse('-h TOPIC  Descripton... [default: 2]') ==
               Option('-h', nil, 1, '2')
    assert Option.parse('-h TOPIC  Descripton... [default: topic-1]') ==
               Option('-h', nil, 1, 'topic-1')
    assert Option.parse('--help=TOPIC  ... [default: 3.14]') ==
               Option(nil, '--help', 1, '3.14')
    assert Option.parse('-h, --help=DIR  ... [default: ./]') ==
               Option('-h', '--help', 1, "./")
    assert Option.parse('-h TOPIC  Descripton... [dEfAuLt: 2]') ==
               Option('-h', nil, 1, '2')

  end


  def test_option_name
    assert_equal '-h', Option('-h', nil).name
    assert_equal '--help', Option('-h', '--help').name
    assert_equal '--help', Option(nil, '--help').name
  end

  def test_any_options
    doc = <<-EOS
    Usage: prog [options] A

    -q  Be quiet
    -v  Be verbose.
    EOS
    assert_equal({'A' => 'arg', '-v' => false, '-q' => false}, docopt(doc, 'arg'))
    assert_equal({'A' => 'arg', '-v' => true, '-q' => false}, docopt(doc, '-v arg'))
    assert_equal({'A' => 'arg', '-v' => false, '-q' => true}, docopt(doc, '-q arg'))
  end

  def test_commands
    assert_equal({'add' => true}, docopt('Usage: prog add', 'add'))
    assert_equal({'add' => false}, docopt('Usage: prog [add]', ''))
    assert_equal({'add' => true}, docopt('Usage: prog [add]', 'add'))
    assert_equal({'add' => true, 'rm' => false}, docopt('Usage: prog (add|rm)', 'add'))
    assert_equal({'add' => false, 'rm' => true}, docopt('Usage: prog (add|rm)', 'rm'))
    assert_equal({'a' => true, 'b' => true}, docopt('Usage: prog a b', 'a b'))
    assert_raise(Docopt::Exit) { docopt('Usage: prog a b',  'b a') }
  end

  def test_parse_doc_options
    doc = <<-EOS
    -h, --help  Print help message.
    -o FILE     Output file.
    --verbose   Verbose mode.
    EOS
    assert_equal [Option('-h', '--help'), Option('-o', nil, 1), Option(nil, '--verbose')], parse_doc_options(doc)
  end

  def test_printable_and_formal_usage
    doc = <<-EOS
    Usage: prog [-hv] ARG
           prog N M

    prog is a program.
    EOS

    assert_equal "Usage: prog [-hv] ARG\n           prog N M",  printable_usage(doc)
    assert_equal "( [-hv] ARG ) | ( N M )",  formal_usage(printable_usage(doc))
    assert_equal "uSaGe: prog ARG",  printable_usage("uSaGe: prog ARG\n\t \t\n bla")
  end

  def test_parse_argv
    o = [Option('-h'), Option('-v', '--verbose'), Option('-f', '--file', 1)]
    assert_equal [], parse_argv('', options=o)
    assert_equal [Option('-h', nil, 0, true)], parse_argv('-h', options=o)
    assert_equal [Option('-h', nil, 0, true), Option('-v', '--verbose', 0, true)],
           parse_argv('-h --verbose', options=o)

    assert_equal [Option('-h', nil, 0, true), Option('-f', '--file', 1, 'f.txt')],
            parse_argv('-h --file f.txt', options=o)

    assert_equal [Option('-h', nil, 0, true), Option('-f', '--file', 1, 'f.txt'), Argument(nil, 'arg')],
            parse_argv('-h --file f.txt arg', options=o)

    assert_equal [Option('-h', nil, 0, true), Option('-f', '--file', 1, 'f.txt'), Argument(nil, 'arg'), Argument(nil, 'arg2')],
            parse_argv('-h --file f.txt arg arg2', options=o)

    assert_equal [Option('-h', nil, 0, true), Argument(nil, 'arg'), Argument(nil, '--'), Argument(nil, '-v')],
            parse_argv('-h arg -- -v', options=o)
  end

  def test_parse_pattern
    o = [Option('-h'), Option('-v', '--verbose'), Option('-f', '--file', 1)]
    assert parse_pattern('[ -h ]', options=o) ==
               Required(Optional(Option('-h')))

    assert parse_pattern('[ ARG ... ]', options=o) ==
               Required(Optional(OneOrMore(Argument('ARG'))))

    assert parse_pattern('[ -h | -v ]', options=o) ==
               Required(Optional(Either(Option('-h'),
                                Option('-v', '--verbose'))))
    assert parse_pattern('( -h | -v [ --file <f> ] )', options=o) ==
               Required(Required(
                   Either(Option('-h'),
                          Required(Option('-v', '--verbose'),
                               Optional(Option('-f', '--file', 1, nil))))))

    assert parse_pattern('(-h|-v[--file=<f>]N...)', options=o) ==
               Required(Required(Either(Option('-h'),
                              Required(Option('-v', '--verbose'),
                                  Optional(Option('-f', '--file', 1, nil)),
                                     OneOrMore(Argument('N'))))))

    assert parse_pattern('(N [M | (K | L)] | O P)', options=[]) ==
               Required(Required(Either(
                   Required(Argument('N'),
                            Optional(Either(Argument('M'),
                                            Required(Either(Argument('K'),
                                                            Argument('L')))))),
                   Required(Argument('O'), Argument('P')))))

    assert parse_pattern('[ -h ] [N]', options=o) ==
               Required(Optional(Option('-h')),
                        Optional(Argument('N')))

    assert parse_pattern('[options]', options=o) == Required(
                Optional(*o))

    assert parse_pattern('[options] A', options=o) == Required(
                Optional(*o),
                Argument('A'))

    assert parse_pattern('-v [options]', options=o) == Required(
                Option('-v', '--verbose'),
                Optional(*o))

    assert parse_pattern('ADD', options=o) == Required(Argument('ADD'))
    assert parse_pattern('<add>', options=o) == Required(Argument('<add>'))
    assert parse_pattern('add', options=o) == Required(Command('add'))
  end

  def test_option_match
    assert Option('-a').match([Option('-a', nil, 0, true)]) ==
            [true, [], [Option('-a', nil, 0, true)]]
    assert Option('-a').match([Option('-x')]) == [false, [Option('-x')], []]
    assert Option('-a').match([Argument('N')]) == [false, [Argument('N')], []]
    assert Option('-a').match([Option('-x'), Option('-a'), Argument('N')]) ==
            [true, [Option('-x'), Argument('N')], [Option('-a')]]
    assert Option('-a').match([Option('-a', nil, 0, true), Option('-a')]) ==
            [true, [Option('-a')], [Option('-a', nil, 0, true)]]
  end

  def test_argument_match
    assert_equal [true, [], [Argument('N', 9)]],
                  Argument('N').match([Argument(nil, 9)])
    assert_equal [false, [Option('-x')], []],
                  Argument('N').match([Option('-x')])
    assert_equal [true, [Option('-x'), Option('-a')], [Argument('N', 5)]],
                  Argument('N').match([Option('-x'), Option('-a'), Argument(nil, 5)])
    assert_equal [true, [Argument(nil, 0)], [Argument('N', 9)]],
                  Argument('N').match([Argument(nil, 9), Argument(nil, 0)])
  end

  def test_command_match
    assert_equal [true, [], [Command('c', true)]],
                  Command('c').match([Argument(nil, 'c')])
    assert_equal [false, [Option('-x')], []],
                  Command('c').match([Option('-x')])
    assert_equal [true, [Option('-x'), Option('-a')], [Command('c', true)]],
                  Command('c').match([Option('-x'), Option('-a'), Argument(nil, 'c')])
    assert_equal [true, [], [Command('rm', true)]],
                  Either(Command('add', false), Command('rm', false)).match([Argument(nil, 'rm')])
  end

  def test_optional_match
    assert_equal [true, [], [Option('-a')]],
                  Optional(Option('-a')).match([Option('-a')])
    assert_equal [true, [], []],
                  Optional(Option('-a')).match([])
    assert_equal [true, [Option('-x')], []],
                  Optional(Option('-a')).match([Option('-x')])
    assert_equal [true, [], [Option('-a')]],
                  Optional(Option('-a'), Option('-b')).match([Option('-a')])
    assert_equal [true, [], [Option('-b')]],
                  Optional(Option('-a'), Option('-b')).match([Option('-b')])
    assert_equal [true, [Option('-x')], []],
                  Optional(Option('-a'), Option('-b')).match([Option('-x')])
    assert_equal [true, [], [Argument('N', 9)]],
                  Optional(Argument('N')).match([Argument(nil, 9)])
    assert_equal [true, [Option('-x')], [Option('-a'), Option('-b')]],
                  Optional(Option('-a'), Option('-b')).match([Option('-b'), Option('-x'), Option('-a')])
  end

  def test_required_match
    assert_equal [true, [], [Option('-a')]],
                  Required(Option('-a')).match([Option('-a')])
    assert_equal [false, [], []],
                  Required(Option('-a')).match([])
    assert_equal [false, [Option('-x')], []],
                  Required(Option('-a')).match([Option('-x')])
    assert_equal [false, [Option('-a')], []],
                  Required(Option('-a'), Option('-b')).match([Option('-a')])
  end

  def test_either_match
    assert_equal [true, [], [Option('-a')]],
                  Either(Option('-a'), Option('-b')).match([Option('-a')])
    assert_equal [true, [Option('-b')], [Option('-a')]],
                  Either(Option('-a'), Option('-b')).match([Option('-a'), Option('-b')])
    assert_equal [false, [Option('-x')], []],
                  Either(Option('-a'), Option('-b')).match([Option('-x')])
    assert_equal [true, [Option('-x')], [Option('-b')]],
                  Either(Option('-a'), Option('-b'), Option('-c')).match([Option('-x'), Option('-b')])
    assert_equal [true, [], [Argument('N', 1), Argument('M', 2)]],
                  Either(Argument('M'), Required(Argument('N'), Argument('M'))).match([Argument(nil, 1), Argument(nil, 2)])
  end

  def test_one_or_more_match
    assert_equal [true, [], [Argument('N', 9)]],
                  OneOrMore(Argument('N')).match([Argument(nil, 9)])
    assert_equal [false, [], []],
                  OneOrMore(Argument('N')).match([])
    assert_equal [false, [Option('-x')], []],
                  OneOrMore(Argument('N')).match([Option('-x')])
    assert_equal [true, [], [Argument('N', 9), Argument('N', 8)]],
                  OneOrMore(Argument('N')).match([Argument(nil, 9), Argument(nil, 8)])
    assert_equal [true, [Option('-x')], [Argument('N', 9), Argument('N', 8)]],
                  OneOrMore(Argument('N')).match([Argument(nil, 9), Option('-x'), Argument(nil, 8)])
    assert_equal [true, [Argument(nil, 8)], [Option('-a'), Option('-a')]],
                  OneOrMore(Option('-a')).match([Option('-a'), Argument(nil, 8), Option('-a')])
    assert_equal [false, [Argument(nil, 8), Option('-x')], []],
                  OneOrMore(Option('-a')).match([Argument(nil, 8), Option('-x')])
    assert_equal [true, [Option('-x')], [Option('-a'), Argument('N', 1), Option('-a'), Argument('N', 2)]],
                  OneOrMore(Required(Option('-a'), Argument('N'))).match([Option('-a'), Argument(nil, 1), Option('-x'), Option('-a'), Argument(nil, 2)])
    assert_equal [true, [], [Argument('N', 9)]],
                  OneOrMore(Optional(Argument('N'))).match([Argument(nil, 9)])
  end

  def test_list_argument_match
    assert_equal [true, [], [Argument('N', ['1', '2'])]],
                  Required(Argument('N'), Argument('N')).fix().match([Argument(nil, '1'), Argument(nil, '2')])

    assert_equal [true, [], [Argument('N', ['1', '2', '3'])]],
                  OneOrMore(Argument('N')).fix().match([Argument(nil, '1'), Argument(nil, '2'), Argument(nil, '3')])

    assert_equal [true, [], [Argument('N', ['1', '2', '3'])]],
                  Required(Argument('N'), OneOrMore(Argument('N'))).fix().match([Argument(nil, '1'), Argument(nil, '2'), Argument(nil, '3')])
    assert_equal [true, [], [Argument('N', ['1', '2'])]],
                  Required(Argument('N'), Required(Argument('N'))).fix().match([Argument(nil, '1'), Argument(nil, '2')])
  end

  def test_basic_pattern_matching
    # ( -a N [ -x Z ] )
    pattern = Required(Option('-a'), Argument('N'),
                       Optional(Option('-x'), Argument('Z')))
    # -a N
    assert_equal [true, [], [Option('-a'), Argument('N', 9)]],
                  pattern.match([Option('-a'), Argument(nil, 9)])

    # -a -x N Z
    assert_equal [true, [], [Option('-a'), Argument('N', 9), Option('-x'), Argument('Z', 5)]],
                  pattern.match([Option('-a'), Option('-x'), Argument(nil, 9), Argument(nil, 5)])

    # -x N Z  # BZZ!
    assert_equal [false, [Option('-x'), Argument(nil, 9), Argument(nil, 5)], []],
                  pattern.match([Option('-x'), Argument(nil, 9), Argument(nil, 5)])
  end

  def test_pattern_either
    assert Option('-a').either == Either(Required(Option('-a')))
    assert Argument('A').either == Either(Required(Argument('A')))
    assert Required(Either(Option('-a'), Option('-b')), Option('-c')).either ==
            Either(Required(Option('-a'), Option('-c')),
                   Required(Option('-b'), Option('-c')))
    assert Optional(Option('-a'), Either(Option('-b'), Option('-c'))).either ==
            Either(Required(Option('-b'), Option('-a')),
                   Required(Option('-c'), Option('-a')))
    assert Either(Option('-x'), Either(Option('-y'), Option('-z'))).either ==
            Either(Required(Option('-x')),
                   Required(Option('-y')),
                   Required(Option('-z')))
    assert OneOrMore(Argument('N'), Argument('M')).either ==
            Either(Required(Argument('N'), Argument('M'),
                            Argument('N'), Argument('M')))
  end

  def test_pattern_fix_list_arguments
    assert_equal Option('-a'),  Option('-a').fix_list_arguments()
    assert_equal Argument('N', nil),  Argument('N', nil).fix_list_arguments()
    assert_equal Required(Argument('N', []), Argument('N', [])),
                  Required(Argument('N'), Argument('N')).fix_list_arguments()
    assert_equal Either(Argument('N', []), OneOrMore(Argument('N', []))),
                  Either(Argument('N'), OneOrMore(Argument('N'))).fix()
  end

  def test_set
    assert Argument('N') == Argument('N')
    assert Set.new([Argument('N'), Argument('N')]) == Set.new([Argument('N')])  # It fails
  end

  def test_pattern_fix_identities_1
    pattern = Required(Argument('N'), Argument('N'))
    assert pattern.children[0] == pattern.children[1]
    refute pattern.children[0].eql?(pattern.children[1])
    pattern.fix_identities()
    assert pattern.children[0].eql? pattern.children[1]
  end
  def test_pattern_fix_identities_2
    pattern = Required(Optional(Argument('X'), Argument('N')), Argument('N'))
    assert pattern.children[0].children[1] == pattern.children[1]
    refute pattern.children[0].children[1].eql? pattern.children[1]
    pattern.fix_identities()
    assert pattern.children[0].children[1].eql? pattern.children[1]
  end

  def test_long_options_error_handling
  #    assert_raise(DocoptLanguageError) { docopt('Usage: prog --non-existent', '--non-existent') }
  #    assert_raise(DocoptLanguageError) { docopt('Usage: prog --non-existent') }
    assert_raise(Docopt::Exit) { docopt('Usage: prog', '--non-existent') }
    assert_raise(Docopt::Exit) {docopt("Usage: prog [--version --verbose]\n\n--version\n--verbose", '--ver') }
    assert_raise(Docopt::DocoptLanguageError) { docopt("Usage: prog --long\n\n--long ARG") }
    assert_raise(Docopt::Exit) { docopt("Usage: prog --long ARG\n\n--long ARG", '--long') }
    assert_raise(Docopt::DocoptLanguageError) { docopt("Usage: prog --long=ARG\n\n--long") }
    assert_raise(Docopt::Exit) { docopt("Usage: prog --long\n\n--long", '--long=ARG') }
  end

  def test_short_options_error_handling
    assert_raise(Docopt::DocoptLanguageError) { docopt("Usage: prog -x\n\n-x  this\n-x  that") }

#    assert_raise(Docopt::DocoptLanguageError) { docopt('Usage: prog -x') }
    assert_raise(Docopt::Exit) { docopt('Usage: prog', '-x') }

    assert_raise(Docopt::DocoptLanguageError) { docopt("Usage: prog -o\n\n-o ARG") }
    assert_raise(Docopt::Exit) { docopt("Usage: prog -o ARG\n\n-o ARG", '-o') }
  end

  def test_matching_paren
    assert_raise(Docopt::DocoptLanguageError) { docopt('Usage: prog [a [b]') }
    assert_raise(Docopt::DocoptLanguageError) { docopt('Usage: prog [a [b] ] c )') }
  end

  def test_allow_double_underscore
    # It fails: '--' yields option {'--' => '--'} but not {'--' => true}
    assert_equal( {'-o' => false, '<arg>' => '-o', '--' => true},
                  docopt("usage: prog [-o] [--] <arg>\n\n-o", '-- -o') )
    assert_equal( {'-o' => true, '<arg>' => '1', '--' => false},
                  docopt("usage: prog [-o] [--] <arg>\n\n-o", '-o 1') )
    assert_raise(Docopt::Exit) {
      docopt("usage: prog [-o] <arg>\n\n-o", '-- -o')  # '--' not allowed
    }
  end

  def test_allow_single_underscore
    # It fails: '-' yields option {'-' => '-'} but not {'-' => true}
    assert_equal({'-' => true},  docopt('usage: prog [-]', '-'))
    assert_equal({'-' => false}, docopt('usage: prog [-]', ''))
  end

  def test_allow_empty_pattern
    assert_equal({}, docopt('usage: prog', ''))
  end

  def test_docopt
    doc = <<-EOS
    Usage: prog [-v] A

    -v  Be verbose.
    EOS
    assert_equal({'-v' => false, 'A' => 'arg'}, docopt(doc, 'arg'))
    assert_equal({'-v' => true, 'A' => 'arg'},  docopt(doc, '-v arg'))


    doc = <<-EOS
    Usage: prog [-vqr] [FILE]
              prog INPUT OUTPUT
              prog --help

    Options:
      -v  print status messages
      -q  report only file names
      -r  show all occurrences of the same error
      --help

    EOS

    assert_equal( {'-v' => true, '-q' => false, '-r' => false, '--help' => false, 'FILE' => 'file.py', 'INPUT' => nil, 'OUTPUT' => nil},
                 docopt(doc, '-v file.py') )

    assert_equal( {'-v' => true, '-q' => false, '-r' => false, '--help' => false, 'FILE' => nil, 'INPUT' => nil, 'OUTPUT' => nil},
                 docopt(doc, '-v') )

    assert_raise(Docopt::Exit) {  # does not match
        docopt(doc, '-v input.py output.py')
    }

    assert_raise(Docopt::Exit) { docopt(doc, '--fake') }

    assert_raise(Docopt::Exit) { docopt(doc, '--hel') }

    #assert_raise(Docopt::Exit) {
    #    docopt(doc, 'help')  XXX Maybe help command?
    #}
  end

  def test_bug_not_list_argument_if_nothing_matched
    d = 'usage: prog [NAME [NAME ...]]'
    assert_equal({'NAME' => ['a', 'b']}, docopt(d, 'a b'))
    assert_equal({'NAME' => []}, docopt(d, ''))
  end

  def test_option_arguments_default_to_none
    d = <<-EOS
    usage: prog [options]

    -a        Add
    -m <msg>  Message

    EOS
    assert_equal({'-m' => nil, '-a' => true}, docopt(d, '-a'))
  end

  def test_options_without_description
    assert_equal({'--hello' => true},
                  docopt('usage: prog --hello', '--hello'))
    assert_equal({'--hello' => nil},
                  docopt('usage: prog [--hello=<world>]', ''))
    assert_equal({'--hello' => 'wrld'},
                  docopt('usage: prog [--hello=<world>]', '--hello wrld'))
    assert_equal({'-o' => false},
                  docopt('usage: prog [-o]', ''))
    assert_equal({'-o' => true},
                  docopt('usage: prog [-o]', '-o'))
    assert_equal({'-o' => true, '-p' => true, '-r' => false},
                  docopt('usage: prog [-opr]', '-op'))
    assert_equal({'-v' => true, '--verbose' => false},
                  docopt('usage: git [-v | --verbose]', '-v'))
    assert_equal({'remote' => true, '-v' => true, '--verbose' => false},
                  docopt('usage: git remote [-v | --verbose]', 'remote -v'))
  end

  def test_language_errors
    assert_raise(Docopt::DocoptLanguageError) { docopt('no usage with colon here') }
    assert_raise(Docopt::DocoptLanguageError) { docopt("usage: here \n\n and again usage: here") }
  end

  def test_bug
    assert_equal({}, docopt('usage: prog', ''))
    assert_equal({'<a>' => '1', '<b>' => '2'},
                  docopt("usage: prog \n prog <a> <b>", '1 2'))
    assert_equal({'<a>' => nil, '<b>' => nil},
                  docopt("usage: prog \n prog <a> <b>", ''))
    assert_equal({'<a>' => nil, '<b>' => nil}, docopt("usage: prog <a> <b> \n prog", ''))
  end

  def test_issue40
    assert_raise(Docopt::Exit) {  # i.e. shows help
        docopt('usage: prog --help-commands | --help', '--help')
    }
    assert_equal({'--aabb' => false, '--aa' => true}, docopt('usage: prog --aabb | --aa', '--aa'))
  end

def test_bug_option_argument_should_not_capture_default_value_from_pattern
    assert_equal({'--file' => nil}, docopt('usage: prog [--file=<f>]', ''))
    assert_equal({'--file' => nil}, docopt("usage: prog [--file=<f>]\n\n--file <a>", ''))

    doc = <<-EOS
    Usage: tau [-a <host:port>]

    -a, --address <host:port>  TCP address [default: localhost:6283].

    EOS
    assert_equal({'--address' => 'localhost:6283'}, docopt(doc, ''))
  end

#def test_issue34_unicode_strings
#    try:
#        assert docopt(eval("u'usage: prog [-o <a>]'"), '') == \
#                {'-o' => false, '<a>' => nil}
#    except SyntaxError:
#        pass  # Python 3

  def test_count_multiple_flags
    assert_equal({'-v' => true}, docopt('usage: prog [-v]', '-v'))
    assert_equal({'-v' => 0}, docopt('usage: prog [-vv]', ''))
    assert_equal({'-v' => 1}, docopt('usage: prog [-vv]', '-v'))
    assert_equal({'-v' => 2}, docopt('usage: prog [-vv]', '-vv'))

    assert_raise(Docopt::Exit) {
      assert_equal docopt('usage: prog [-vv]', '-vvv')
    }

    assert_equal({'-v' => 3}, docopt('usage: prog [-v | -vv | -vvv]', '-vvv'))
    assert_equal({'-v' => 6}, docopt('usage: prog -v...', '-vvvvvv'))
    assert_equal({'--ver' => 2}, docopt('usage: prog [--ver --ver]', '--ver --ver'))
  end

  def test_count_multiple_commands
    assert_equal({'go' => true}, docopt('usage: prog [go]', 'go'))
    assert_equal({'go' => 0}, docopt('usage: prog [go go]', ''))
    assert_equal({'go' => 1}, docopt('usage: prog [go go]', 'go'))
    assert_equal({'go' => 2}, docopt('usage: prog [go go]', 'go go'))

    assert_raise(Docopt::Exit) {
      assert docopt('usage: prog [go go]', 'go go go')  ## WTF ???!!!
    }
    assert_equal({'go' => 5}, docopt('usage: prog go...', 'go go go go go'))
  end


  def test_accumulate_multiple_options
    assert_equal({'--long' => ['one']}, docopt('usage: prog --long=<arg> ...', '--long one'))
    assert_equal({'--long' => ['one', 'two']}, docopt('usage: prog --long=<arg> ...', '--long one --long two'))
  end


  def test_multiple_different_elements
    assert_equal({'go' => 2, '<direction>' => ['left', 'right'], '--speed' => ['5', '9']},
                  docopt('usage: prog (go <direction> --speed=<km/h>)...', 'go left --speed=5  go right --speed=9'))
  end
end