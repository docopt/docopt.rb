require 'getoptlong'


class Option

    attr_accessor :short
    attr_accessor :long
    attr_accessor :value

    def initialize(short=nil, long=nil, value=false)
        @short = short
        @long = long
        @value = value
    end

    def is_flag
        if @short
            return !(@short.end_with(':'))
        elsif @long
            return !(@long.end_with('='))
        end
    end

    def name
        variabalize((@long or @short).sub(':', '').sub('=', ''))
    end

    def to_s
        "Option.new(#{@short}, #{@long}, #{@value})"
    end

    def == other
        self.to_s == other.to_s
    end

end


def option parse
    is_flag = true
    short, long, value = nil, nil, false
    split = parse.strip.split('  ')
    options = split[0].sub(',', ' ').sub('=', ' ')
    description = split[1..-1] * ''
    for s in options.split
        if s.start_with? '--'
            long = s[2..-1]
        elsif s.start_with? '-'
            short = s[1..-1]
        else
            is_flag = false
        end
    end
    if not is_flag
        matched = description.scan(/\[default: (.*)\]/)[0]
        value = matched ? matched[0] : false
        short = short ? short + ':' : nil
        long = long ? long + '=' : nil
    end
    Option.new(short, long, value)
end


#def docopt(doc, argv=ARGV, help=true, version=nil)
#    docopts = [option('-' + s) for s in re.split('^ *-|\n *-', doc)[1:]]
#
#opts = GetoptLong.new(
#  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
#  [ '--repeat', '-n', GetoptLong::REQUIRED_ARGUMENT ]
#)
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
#end

if __FILE__ == $0

    def assert cond
        print cond ? '.' : 'F'
    end

    assert option('-h') == Option.new('h', nil)
    assert option('--help') == Option.new(nil, 'help')
    assert option('-h --help') == Option.new('h', 'help')
    assert option('-h, --help') == Option.new('h', 'help')

    assert option('-h TOPIC') == Option.new('h:', nil)
    assert option('--help TOPIC') == Option.new(nil, 'help=')
    assert option('-h TOPIC --help TOPIC') == Option.new('h:', 'help=')
    assert option('-h TOPIC, --help TOPIC') == Option.new('h:', 'help=')
    assert option('-h TOPIC, --help=TOPIC') == Option.new('h:', 'help=')

    assert option('-h  Description...') == Option.new('h', nil)
    assert option('-h --help  Description...') == Option.new('h', 'help')
    assert option('-h TOPIC  Description...') == Option.new('h:', nil)

    assert option('    -h') == Option.new('h', nil)

    assert option('-h TOPIC  Descripton... [default: 2]') ==
               Option.new('h:', nil, '2')
    assert option('-h TOPIC  Descripton... [default: topic-1]') ==
               Option.new('h:', nil, 'topic-1')
    assert option('--help=TOPIC  ... [default: 3.14]') ==
               Option.new(nil, 'help=', '3.14')
    assert option('-h, --help=DIR  ... [default: ./]') ==
               Option.new('h:', 'help=', "./")
end
