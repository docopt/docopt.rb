require 'getoptlong'


class Option

    attr_reader :short, :long, :argcount, :value

    def initialize(short=nil, long=nil, argcount=0, value=false)
        @short, @long, @argcount, @value = short, long, argcount, value
    end

    def getopt
        [@long, @short, @argcount].compact
    end

    def inspect
        "Option.new(#{@short}, #{@long}, #{@argcount}, #{@value})"
    end

    def == other
        self.inspect == other.inspect
    end

end


def option parse
    options, _, description = parse.strip.partition('  ')
    options = options.sub(',', ' ').sub('=', ' ')
    short, long, argcount, value = nil, nil, 0, false
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


def docopt(doc, version=nil, help=true)
    ret = {}
    docopts = []
    doc.split(/^ *-|\n *-/)[1..-1].each do |s|
        docopt = option('-' + s)
        docopts += [docopt]
        ret[(docopt.long or docopt.short)] = docopt.value
    end
    begin
        GetoptLong.new(*docopts.map {|e| e.getopt}).each do |opt, arg|
            if help and (opt == '--help' or opt == '-h')
                puts doc.strip
                exit
            elsif version and opt == '--version'
                puts version
                exit
            elsif (docopts.select {|d|(d.long or d.short)==opt})[0].argcount==0
                ret[opt] = true
            else
                ret[opt] = arg
            end
        end
    rescue
        exit 1
    end
    ret
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
