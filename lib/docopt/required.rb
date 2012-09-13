require_relative 'parent_pattern'

module Docopt
  class Required < ParentPattern
    def match(left, collected=nil)
      collected ||= []
      l = left
      c = collected

      for p in self.children
        matched, l, c = p.match(l, c)
        if not matched
          return [false, left, collected]
        end
      end
      return [true, l, c]
    end
  end
end