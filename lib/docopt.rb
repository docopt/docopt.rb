require_relative 'docopt/exit'
require_relative 'docopt/pattern'
require_relative 'docopt/child_pattern'
require_relative 'docopt/parent_pattern'
require_relative 'docopt/argument'
require_relative 'docopt/command'
require_relative 'docopt/option'
require_relative 'docopt/required'
require_relative 'docopt/optional'
require_relative 'docopt/one_or_more'
require_relative 'docopt/either'
require_relative 'docopt/token_stream'
require_relative 'docopt/docopt_language_error'

module Docopt
  VERSION = '0.5.0'
end

module Docopt
  class << self
    def parse_long(tokens, options)
      raw, eq, value = tokens.move().partition('=')
      value = (eq == value and eq == '') ? nil : value

      opt = options.select { |o| o.long and o.long == raw }

      if tokens.error == Exit and opt == []
        opt = options.select { |o| o.long and o.long.start_with?(raw) }
      end

      if opt.count < 1
        if tokens.error == Exit
          raise tokens.error, "#{raw} is not recognized"
        else
          o = Option.new(nil, raw, eq == '=' ? 1 : 0)
          options << o
          return [o]
        end
      end
      if opt.count > 1
        ostr = opt.map { |o| o.long }.join(', ')
        raise tokens.error, "#{raw} is not a unique prefix: #{ostr}?"
      end
      o = opt[0]
      opt = Option.new(o.short, o.long, o.argcount, o.value)
      if opt.argcount == 1
        if value == nil
          if tokens.current() == nil
            raise tokens.error, "#{opt.name} requires argument"
          end
          value = tokens.move()
        end
      elsif value != nil
        raise tokens.error, "#{opt.name} must not have an argument"
      end

      if tokens.error == Exit
        opt.value = value ? value : true
      else
        opt.value = value ? nil : false
      end
      return [opt]
    end

    def parse_shorts(tokens, options)
      raw = tokens.move()[1..-1]
      parsed = []
      while raw != ''
        first = raw.slice(0, 1)
        opt = options.select { |o| o.short and o.short.sub(/^-+/, '').start_with?(first) }

        if opt.count > 1
          raise tokens.error, "-#{first} is specified ambiguously #{opt.count} times"
        end

        if opt.count < 1
          if tokens.error == Exit
            raise tokens.error, "-#{first} is not recognized"
          else
            o = Option.new('-' + first, nil)
            options << o
            parsed << o
            raw = raw[1..-1]
            next
          end
        end

        o = opt[0]
        opt = Option.new(o.short, o.long, o.argcount, o.value)
        raw = raw[1..-1]
        if opt.argcount == 0
          value = tokens.error == Exit ? true : false
        else
          if raw == ''
            if tokens.current() == nil
              raise tokens.error, "-#{opt.short.slice(0, 1)} requires argument"
            end
            raw = tokens.move()
          end
          value, raw = raw, ''
        end

        if tokens.error == Exit
          opt.value = value
        else
          opt.value = value ? nil : false
        end
        parsed << opt
      end
      return parsed
    end


    def parse_pattern(source, options)
      tokens = TokenStream.new(source.gsub(/([\[\]\(\)\|]|\.\.\.)/, ' \1 '), DocoptLanguageError)

      result = parse_expr(tokens, options)
      if tokens.current() != nil
        raise tokens.error, "unexpected ending: #{tokens.join(" ")}"
      end
      return Required.new(*result)
    end


    def parse_expr(tokens, options)
      seq = parse_seq(tokens, options)
      if tokens.current() != '|'
        return seq
      end
      result = seq.count > 1 ? [Required.new(*seq)] : seq

      while tokens.current() == '|'
        tokens.move()
        seq = parse_seq(tokens, options)
        result += seq.count > 1 ? [Required.new(*seq)] : seq
      end
      return result.count > 1 ? [Either.new(*result)] : result
    end

    def parse_seq(tokens, options)
      result = []
      stop = [nil, ']', ')', '|']
      while !stop.include?(tokens.current)
        atom = parse_atom(tokens, options)
        if tokens.current() == '...'
          atom = [OneOrMore.new(*atom)]
          tokens.move()
        end
        result += atom
      end
      return result
    end

    def parse_atom(tokens, options)
      token = tokens.current()
      result = []

      if ['(' , '['].include? token
        tokens.move()
        if token == '('
          matching = ')'
          pattern = Required
        else
          matching = ']'
          pattern = Optional
        end
        result = pattern.new(*parse_expr(tokens, options))
        if tokens.move() != matching
          raise tokens.error, "unmatched '#{token}'"
        end
        return [result]
      elsif token == 'options'
        tokens.move()
        return options
      elsif token.start_with?('--') and token != '--'
        return parse_long(tokens, options)
      elsif token.start_with?('-') and not ['-', '--'].include? token
        return parse_shorts(tokens, options)

      elsif token.start_with?('<') and token.end_with?('>') or token.upcase == token
        return [Argument.new(tokens.move())]
      else
        return [Command.new(tokens.move())]
      end
    end

    def parse_argv(source, options)
      tokens = TokenStream.new(source, Exit)
      parsed = []
      while tokens.current() != nil
        if tokens.current() == '--'
          return parsed + tokens.map { |v| Argument.new(nil, v) }
        elsif tokens.current().start_with?('--')
          parsed += parse_long(tokens, options)
        elsif tokens.current().start_with?('-') and tokens.current() != '-'
          parsed += parse_shorts(tokens, options)
        else
          parsed << Argument.new(nil, tokens.move())
        end
      end
      return parsed
    end

    def parse_doc_options(doc)
      return doc.split(/^ *-|\n *-/)[1..-1].map { |s| Option.parse('-' + s) }
    end

    def printable_usage(doc)
      usage_split = doc.split(/([Uu][Ss][Aa][Gg][Ee]:)/)
      if usage_split.count < 3
        raise DocoptLanguageError, '"usage:" (case-insensitive) not found.'
      end
      if usage_split.count > 3
        raise DocoptLanguageError, 'More than one "usage:" (case-insensitive).'
      end
      return usage_split[1..-1].join().split(/\n\s*\n/)[0].strip
    end

    def formal_usage(printable_usage)
      pu = printable_usage.split()[1..-1]  # split and drop "usage:"

      ret = []
      for s in pu[1..-1]
        if s == pu[0]
          ret << ') | ('
        else
          ret << s
        end
      end

      return '( ' + ret.join(' ') + ' )'
    end

    def dump_patterns(pattern, indent=0)
      ws = " " * 4 * indent
      out = ""
      if pattern.class == Array
        if pattern.count > 0
          out << ws << "[\n"
          for p in pattern
            out << dump_patterns(p, indent+1).rstrip << "\n"
          end
          out << ws << "]\n"
        else
          out << ws << "[]\n"
        end

      elsif pattern.class.ancestors.include?(ParentPattern)
        out << ws << pattern.class.name << "(\n"
        for p in pattern.children
          out << dump_patterns(p, indent+1).rstrip << "\n"
        end
        out << ws << ")\n"

      else
        out << ws << pattern.inspect
      end
      return out
    end

    def extras(help, version, options, doc)
      ofound = false
      vfound = false
      for o in options
        if o.value and (o.name == '-h' or o.name == '--help')
          ofound = true
        end
        if o.value and (o.name == '--version')
          vfound = true
        end
      end

      if help and ofound
        Exit.set_usage(nil)
        raise Exit, doc.strip
      end
      if version and vfound
        Exit.set_usage(nil)
        raise Exit, version
      end
    end

    def docopt(doc, params={})
      default = {:version => nil, :argv => nil, :help => true}
      params = default.merge(params)
      params[:argv] = ARGV if !params[:argv]

      Exit.set_usage(printable_usage(doc))
      options = parse_doc_options(doc)
      pattern = parse_pattern(formal_usage(Exit.usage), options)
      argv = parse_argv(params[:argv], options)
      extras(params[:help], params[:version], argv, doc)

      matched, left, collected = pattern.fix().match(argv)
      collected ||= []

      if matched and (!left or left.count == 0)
        ret = {}
        for a in pattern.flat + options + collected
          name = a.name
          if name and name != ''
            ret[name] = a.value
          end
        end
        return ret
      end
      raise Exit
    end
  end
end
