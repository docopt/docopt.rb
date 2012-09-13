require_relative 'child_pattern'

module Docopt
  class Argument < ChildPattern

    # def initialize(*args)
    #   super(*args)
    # end

    def single_match(left)
      left.each_with_index do |p, n|
        if p.class == Argument
          return [n, Argument.new(self.name, p.value)]
        end
      end
      return [nil, nil]
    end
  end
end