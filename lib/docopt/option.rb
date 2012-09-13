require_relative 'child_pattern'

module Docopt
  class Option < ChildPattern
    attr_reader :short, :long
    attr_accessor :argcount

    def initialize(short=nil, long=nil, argcount=0, value=false)
      unless [0, 1].include? argcount
        raise RuntimeError
      end

      @short, @long = short, long
      @argcount, @value = argcount, value

      if value == false and argcount > 0
        @value = nil
      else
        @value = value
      end
    end

    def self.parse(option_description)
      short, long, argcount, value = nil, nil, 0, false
      options, _, description = option_description.strip.partition('  ')

      options.gsub!(",", " ")
      options.gsub!("=", " ")

      for s in options.split
        if s.start_with?('--')
          long = s
        elsif s.start_with?('-')
          short = s
        else
          argcount = 1
        end
      end
      if argcount > 0
        matched = description.scan(/\[default: (.*)\]/i)
        value = matched[0][0] if matched.count > 0
      end
      ret = self.new(short, long, argcount, value)
      return ret
    end

    def single_match(left)
      left.each_with_index do |p, n|
        if self.name == p.name
          return [n, p]
        end
      end
      return [nil, nil]
    end

    def name
      return self.long ? self.long : self.short
    end

    def inspect
      return "Option(#{self.short}, #{self.long}, #{self.argcount}, #{self.value})"
    end
  end
end