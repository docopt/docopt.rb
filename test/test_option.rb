require 'test/unit'

class OptionTest < Test::Unit::TestCase    
  # Convenience methods
  def assert_option text, short, long, argcount = 0, value=false
    option = Docopt::Option.new text
    assert_equal short, option.short
    assert_equal long, option.long
    assert_equal argcount, option.argcount
    if value
      assert_equal value, option.value
    else
      assert_equal nil, option.value
    end

  end
    
    
  # Test cases
  def test_short
    assert_option '-h', '-h', nil
    assert_option '    -h', '-h', nil
  end
    
  def test_long
    assert_option '--help', nil, '--help'
    assert_option '    --help', nil, '--help'
      
  end
    
    
  def test_both
    assert_option '-h --help', '-h', '--help'
    assert_option '-h, --help', '-h', '--help'
    assert_option '    -h --help', '-h', '--help'
    assert_option '    -h, --help', '-h', '--help'
  end
    
  def test_short_with_argument
    assert_option '-h TOPIC', '-h', nil, 1
  end
    
  def test_long_with_argument
    assert_option '--help TOPIC', nil, '--help', 1
    assert_option '--help=TOPIC', nil, '--help', 1
  end
    
  def test_both_with_argument
    assert_option '-h TOPIC --help TOPIC', '-h', '--help', 1
    assert_option '-h TOPIC, --help TOPIC', '-h', '--help', 1
    assert_option '-h TOPIC, --help=TOPIC', '-h', '--help', 1
  end
    
  def test_short_with_description
    assert_option '-h  Description...', '-h', nil
  end
    
  def test_long_with_description
    assert_option '--help  Description...', nil, '--help'
  end
    
  def test_both_with_description
    assert_option '-h --help  Description...', '-h', '--help'
    assert_option '-h, --help  Description...', '-h', '--help'
  end
    
  def test_short_with_description_and_argument
    assert_option '-h TOPIC  Description...', '-h', nil, 1
  end
    
  def test_long_with_description_and_argument
    assert_option '--help TOPIC  Description...', nil, '--help', 1
    assert_option '--help=TOPIC  Description...', nil, '--help', 1
  end
    
  def test_both_with_description_and_argument
    assert_option '-h TOPIC --help TOPIC  Description...', '-h', '--help', 1
    assert_option '-h TOPIC, --help TOPIC  Description...', '-h', '--help', 1
    assert_option '-h TOPIC, --help=TOPIC  Description...', '-h', '--help', 1
  end
    
  def test_default
    assert_option '-h TOPIC  Descripton... [default: 2]', '-h', nil, 1, '2'
    assert_option '--help TOPIC  Descripton... [default: topic-1]', nil, '--help', 1, 'topic-1'
    assert_option '--help=TOPIC  ... [default: 3.14]', nil, '--help', 1, '3.14'
    assert_option '-h DIR --help DIR  ... [default: ./]', '-h', '--help', 1, "./"
    assert_option '-h DIR, --help DIR  ... [default: ./]', '-h', '--help', 1, "./"
    assert_option '-h DIR, --help=DIR  ... [default: ./]', '-h', '--help', 1, "./"
  end
    
  def assert_symbol text, symbol
    option = Docopt::Option.new text
    assert option.symbols.include?(symbol)
  end
    
  def test_symbols
    assert_symbol '-h', :h
    assert_symbol '--help', :help
    assert_symbol '-h --help', :h
    assert_symbol '-h --help', :help
  end
end
