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
    
    def set_value val
      if argcount.zero?
        @value = true
      else
        @value = val
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
      docopt_option = option(opt)
      if help and (opt == '--help' or opt == '-h')
        puts doc.strip
        exit
      elsif version and opt == '--version'
        puts version
        exit
      else
        option.set_value arg
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