module Docopt
  class Exit < RuntimeError
    def self.usage
      @@usage
    end

    def self.set_usage(usage)
      @@usage = usage ? usage : ''
    end

    def message
      @@message
    end

    def initialize(message='')
      @@message = ((message && message != '' ? (message + "\n") : '') + @@usage)
    end
  end
end