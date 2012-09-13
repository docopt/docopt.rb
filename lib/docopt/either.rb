require_relative 'parent_pattern'

module Docopt
  class Either < ParentPattern
    def match(left, collected=nil)
      collected ||= []
      outcomes = []
      for p in self.children
        matched, _, _ = outcome = p.match(left, collected)
        if matched
          outcomes << outcome
        end
      end

      if outcomes.count > 0
        ret = outcomes.min_by do |outcome|
          outcome[1] == nil ? 0 : outcome[1].count
        end
        return ret
      end
      return [false, left, collected]
    end
  end
end