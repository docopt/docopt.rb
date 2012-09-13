require_relative 'pattern'

module Docopt
  class ParentPattern < Pattern
    attr_accessor :children

    def initialize(*children)
      @children = children
    end

    def inspect
      childstr = self.children.map { |a| a.inspect }
      return "#{self.class.name}(#{childstr.join(", ")})"
    end

    def flat
      self.children.map { |c| c.flat }.flatten
    end
  end
end