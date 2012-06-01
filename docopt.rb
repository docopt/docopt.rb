require 'getoptlong'


class Option

    attr_reader :short, :long, :argcount, :value

    def initialize(short=nil, long=nil, argcount=0, value=false)
        @short, @long, @argcount, @value = short, long, argcount, value
    end

    def getopt
        [short, long, argcount].compact
    end

    def name
        long or short
    end

    def to_s
        "Option.new(#{@short}, #{@long}, #{@argcount}, #{@value})"
    end

    def == other
        self.to_s == other.to_s
    end

end


def option parse
    short, long, argcount, value = nil, nil, 0, false
    options, _, description = parse.strip.partition('  ')
    options = options.sub(',', ' ').sub('=', ' ')
    for s in options.split
        if s.start_with? '--'
            long = s
        elsif s.start_with? '-'
            short = s
        else
            argcount = 1
        end
    end
    if argcount == 1
        matched = description.scan(/\[default: (.*)\]/)[0]
        value = matched ? matched[0] : false
    end
    Option.new(short, long, argcount, value)
end


def docopt(doc, argv=ARGV, help=true, version=nil)
#    #docopts = [option('-' + s) for s in re.split('^ *-|\n *-', doc)[1:]]

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--repeat', '-n', GetoptLong::REQUIRED_ARGUMENT ]
)
#    try:
#        getopts, args = gnu_getopt(args,
#                            ''.join([d.short for d in docopts if d.short]),
#                            [d.long for d in docopts if d.long])
#    except GetoptError as e:
#        exit(e.msg)
#    for k, v in getopts:
#        for o in docopts:
#            if k in o.forms:
#                o.value = True if o.is_flag else argument_eval(v)
#            end
#            if help and k in ('-h', '--help'):
#                exit(doc.strip())
#            end
#            if version is not None and k == '--version':
#                exit(version)
#            end
#        end
#    end
#    Options.new(**dict([(o.name, o.value) for o in docopts])), args
end

if __FILE__ == $0

    def assert cond
        print cond ? '.' : 'F'
    end

    assert option('-h') == Option.new('-h', nil)
    assert option('--help') == Option.new(nil, '--help')
    assert option('-h --help') == Option.new('-h', '--help')
    assert option('-h, --help') == Option.new('-h', '--help')

    assert option('-h TOPIC') == Option.new('-h', nil, 1)
    assert option('--help TOPIC') == Option.new(nil, '--help', 1)
    assert option('-h TOPIC --help TOPIC') == Option.new('-h', '--help', 1)
    assert option('-h TOPIC, --help TOPIC') == Option.new('-h', '--help', 1)
    assert option('-h TOPIC, --help=TOPIC') == Option.new('-h', '--help', 1)

    assert option('-h  Description...') == Option.new('-h', nil)
    assert option('-h --help  Description...') == Option.new('-h', '--help')
    assert option('-h TOPIC  Description...') == Option.new('-h', nil, 1)

    assert option('    -h') == Option.new('-h', nil)

    assert option('-h TOPIC  Descripton... [default: 2]') ==
               Option.new('-h', nil, 1, '2')
    assert option('-h TOPIC  Descripton... [default: topic-1]') ==
               Option.new('-h', nil, 1, 'topic-1')
    assert option('--help=TOPIC  ... [default: 3.14]') ==
               Option.new(nil, '--help', 1, '3.14')
    assert option('-h, --help=DIR  ... [default: ./]') ==
               Option.new('-h', '--help', 1, "./")
end
