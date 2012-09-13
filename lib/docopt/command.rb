require_relative 'argument'

module Docopt
  class Command < Argument
    def initialize(name, value=false)
      @name = name
      @value = value
    end

    def single_match(left)
      left.each_with_index do |p, n|
        if p.class == Argument
          if p.value == self.name
            return n, Command.new(self.name, true)
          else
            break
          end
        end
      end
      return [nil, nil]
    end
  end
end