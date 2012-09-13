require_relative 'pattern'

module Docopt
  class ChildPattern < Pattern
    attr_accessor :name, :value

    def initialize(name, value=nil)
      @name = name
      @value = value
    end

    def inspect()
      "#{self.class.name}(#{self.name}, #{self.value})"
    end

    def flat
      [self]
    end


    def match(left, collected=nil)
      collected ||= []
      pos, match = self.single_match(left)
      if match == nil
        return [false, left, collected]
      end

      left_ = left.dup
      left_.slice!(pos)

      same_name = collected.select { |a| a.name == self.name }
      if @value.is_a? Array or @value.is_a? Integer
        increment = @value.is_a?(Integer) ? 1 : [match.value]
        if same_name.count == 0
          match.value = increment
          return [true, left_, collected + [match]]
        end
        same_name[0].value += increment
        return [true, left_, collected]
      end
      return [true, left_, collected + [match]]
    end
  end
end