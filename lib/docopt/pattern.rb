module Docopt
  class Pattern
    attr_accessor :children

    def ==(other)
      return self.inspect == other.inspect
    end

    def to_str
      return self.inspect
    end

    def dump
      puts ::Docopt::dump_patterns(self)
    end

    def fix
      fix_identities
      fix_list_arguments
      return self
    end

    def fix_identities(uniq=nil)
      if not instance_variable_defined?(:@children)
        return self
      end
      uniq ||= flat.uniq

      @children.each_with_index do |c, i|
        if not c.instance_variable_defined?(:@children)
          if !uniq.include?(c)
            raise RuntimeError
          end
          @children[i] = uniq[uniq.index(c)]
        else
          c.fix_identities(uniq)
        end
      end
    end

    def fix_list_arguments
      either.children.map { |c| c.children }.each do |case_|
        case_.select { |c| case_.count(c) > 1 }.each do |e|
          if e.class == Argument or (e.class == Option and e.argcount > 0)
            e.value = []
          end
          if e.class == Command or (e.class == Option and e.argcount == 0)
            e.value = 0
          end
        end
      end

      return self
    end

    def either
      ret = []
      groups = [[self]]
      while groups.count > 0
        children = groups.shift
        types = children.map { |c| c.class }

        if types.include?(Either)
          either = children.select { |c| c.class == Either }[0]
          children.slice!(children.index(either))
          for c in either.children
            groups << [c] + children
          end
        elsif types.include?(Required)
          required = children.select { |c| c.class == Required }[0]
          children.slice!(children.index(required))
          groups << required.children + children

        elsif types.include?(Optional)
          optional = children.select { |c| c.class == Optional }[0]
          children.slice!(children.index(optional))
          groups << optional.children + children

        elsif types.include?(OneOrMore)
          oneormore = children.select { |c| c.class == OneOrMore }[0]
          children.slice!(children.index(oneormore))
          groups << (oneormore.children * 2) + children

        else
          ret << children
        end
      end

      args = ret.map { |e| Required.new(*e) }
      return Either.new(*args)
    end
  end
end