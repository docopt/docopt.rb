module Docopt
  class TokenStream < Array
    attr_reader :error

    def initialize(source, error)
      if !source
        source = []
      elsif source.class != ::Array
        source = source.split
      end
      super(source)
      @error = error
    end

    def move
      return self.shift
    end

    def current
      return self[0]
    end
  end
end