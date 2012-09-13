require_relative 'parent_pattern'

module Docopt
  class Optional < ParentPattern
    def match(left, collected=nil)
      collected ||= []
      for p in self.children
        m, left, collected = p.match(left, collected)
      end
      return [true, left, collected]
    end
  end
end