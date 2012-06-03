require 'getoptlong'

class Docopt
  attr_reader :docopts
  
  class UnknownOptionError < StandardError; end
  
  class Option
    attr_reader :short, :long, :argcount, :value
    
    def initialize parse
      @argcount                = 0
      options, _, description = parse.strip.partition('  ')
      options                 = options.sub(',', ' ').sub('=', ' ')

      for s in options.split
        if s.start_with? '--'
          @long = s
        elsif s.start_with? '-'
          @short = s
        else
          @argcount = 1
        end
      end
      
      if @argcount == 1
        matched = description.scan(/\[default: (.*)\]/)[0]
        @value = matched ? matched[0] : nil
      end
    end
    
    def synonyms
      ([short, long] + symbols).compact
    end
    
    def symbols
      [short, long].compact.map do |name|
        name.gsub(/^-+/, '').to_sym
      end
    end

    def getopt
      [long, short, argcount].compact
    end

    def inspect
      "#<Docopt::Option short: #{short}, long: #{long}, argcount: #{argcount}, value: #{value}>"
    end

    def == other
      self.inspect == other.inspect
    end
  end
  
  
  def initialize(doc, version=nil, help=true)
    @docopts = doc.split(/^ *-|\n *-/)[1..-1].map do |line|
      Option.new('-' + line)
    end
    
    GetoptLong.new(*docopts.map(&:getopt)).each do |opt, arg|
      if help and (opt == '--help' or opt == '-h')
        puts doc.strip
        exit
      elsif version and opt == '--version'
        puts version
        exit
      end
    end
  end
  
  def option name
    option = @docopts.detect do |docopt|
      docopt.synonyms.include?(name)
    end
    raise UnknownOptionError.new("#{name} option not found") unless option
    option
  end
  

  
  def value name
    option(name).value
  end
  alias_method :[], :value
    
  def size
    @docopts.size
  end
  
  def inspect
    @docopts.map do |option|
      "#{option.short} #{option.long}=#{option.value.inspect}".strip
    end.join("\n")
  end
end

# Convenience method for Docopt.parse
def Docopt *args
  Docopt.new *args
end

# Tests
if __FILE__ == $0
  require 'test/unit'

  class DocoptTest < Test::Unit::TestCase
    def setup
      $LOAD_PATH << File.dirname(__FILE__)
      load 'example.rb'
      @docopt = Docopt($DOC)
    end
    
    def test_size
      assert_equal 15, @docopt.size
    end
    
    def test_option
      assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt.option('--exclude').value
    end
    
    def test_unknown_option
      assert_raise(Docopt::UnknownOptionError) { @docopt.option('--other') }
      assert_raise(Docopt::UnknownOptionError) { @docopt.option('-o') }
    end
    
    def test_values
      assert_nil @docopt.value('--help')
      assert_nil @docopt.value('-h')
      assert_nil @docopt.value('--version')
      assert_nil @docopt.value('-v')
      assert_nil @docopt.value('--verbose')
      assert_nil @docopt.value('--quiet')
      assert_nil @docopt.value('-q')
      assert_nil @docopt.value('--repeat')
      assert_nil @docopt.value('-r')
      assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt.value('--exclude')
      assert_equal "*.rb", @docopt.value('--filename')
      assert_nil @docopt.value('--select')
      assert_nil @docopt.value('--ignore')
      assert_nil @docopt.value('--show-source')
      assert_nil @docopt.value('--statistics')
      assert_nil @docopt.value('--count')
      assert_nil @docopt.value('--benchmark')
      assert_nil @docopt.value('--testsuite')
      assert_nil @docopt.value('--doctest')
    end
    
    def test_hash_like_access
      assert_nil @docopt['--help']
      assert_nil @docopt['-h']
      assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt['--exclude']
      assert_raise(Docopt::UnknownOptionError) { @docopt['--fakeoption'] }
      assert_raise(Docopt::UnknownOptionError) { @docopt['-f'] }      
    end
    
    def test_symbol_access
      assert_nil @docopt[:help]
      assert_nil @docopt[:h]
      assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt[:exclude]
      assert_raise(Docopt::UnknownOptionError) { @docopt[:fakeoption] }
      assert_raise(Docopt::UnknownOptionError) { @docopt[:f] }      
    end
  end


  class OptionTest < Test::Unit::TestCase
    
    # Convenience methods
    def assert_option text, short, long, argcount = 0, value=false
      option = Docopt::Option.new text
      assert_equal short, option.short
      assert_equal long, option.long
      assert_equal argcount, option.argcount
      if value
        assert_equal value, option.value
      else
        assert_equal nil, option.value
      end

    end
    
    
    # Test cases
    def test_short
      assert_option '-h', '-h', nil
      assert_option '    -h', '-h', nil
    end
    
    def test_long
      assert_option '--help', nil, '--help'
      assert_option '    --help', nil, '--help'
      
    end
    
    
    def test_both
      assert_option '-h --help', '-h', '--help'
      assert_option '-h, --help', '-h', '--help'
      assert_option '    -h --help', '-h', '--help'
      assert_option '    -h, --help', '-h', '--help'
    end
    
    def test_short_with_argument
      assert_option '-h TOPIC', '-h', nil, 1
    end
    
    def test_long_with_argument
      assert_option '--help TOPIC', nil, '--help', 1
      assert_option '--help=TOPIC', nil, '--help', 1
    end
    
    def test_both_with_argument
      assert_option '-h TOPIC --help TOPIC', '-h', '--help', 1
      assert_option '-h TOPIC, --help TOPIC', '-h', '--help', 1
      assert_option '-h TOPIC, --help=TOPIC', '-h', '--help', 1
    end
    
    def test_short_with_description
      assert_option '-h  Description...', '-h', nil
    end
    
    def test_long_with_description
      assert_option '--help  Description...', nil, '--help'
    end
    
    def test_both_with_description
      assert_option '-h --help  Description...', '-h', '--help'
      assert_option '-h, --help  Description...', '-h', '--help'
    end
    
    def test_short_with_description_and_argument
      assert_option '-h TOPIC  Description...', '-h', nil, 1
    end
    
    def test_long_with_description_and_argument
      assert_option '--help TOPIC  Description...', nil, '--help', 1
      assert_option '--help=TOPIC  Description...', nil, '--help', 1
    end
    
    def test_both_with_description_and_argument
      assert_option '-h TOPIC --help TOPIC  Description...', '-h', '--help', 1
      assert_option '-h TOPIC, --help TOPIC  Description...', '-h', '--help', 1
      assert_option '-h TOPIC, --help=TOPIC  Description...', '-h', '--help', 1
    end
    
    def test_default
      assert_option '-h TOPIC  Descripton... [default: 2]', '-h', nil, 1, '2'
      assert_option '--help TOPIC  Descripton... [default: topic-1]', nil, '--help', 1, 'topic-1'
      assert_option '--help=TOPIC  ... [default: 3.14]', nil, '--help', 1, '3.14'
      assert_option '-h DIR --help DIR  ... [default: ./]', '-h', '--help', 1, "./"
      assert_option '-h DIR, --help DIR  ... [default: ./]', '-h', '--help', 1, "./"
      assert_option '-h DIR, --help=DIR  ... [default: ./]', '-h', '--help', 1, "./"
    end
    
    def assert_symbol text, symbol
      option = Docopt::Option.new text
      assert option.symbols.include?(symbol)
    end
    
    def test_symbols
      assert_symbol '-h', :h
      assert_symbol '--help', :help
      assert_symbol '-h --help', :h
      assert_symbol '-h --help', :help
    end
  end

end
