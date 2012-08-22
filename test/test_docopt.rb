require 'test/unit'

class DocoptTest < Test::Unit::TestCase
  def setup
    $LOAD_PATH << File.dirname(__FILE__)
    load 'example.rb'
  end
  
  def get_options(argv=[])
    begin
      Docopt($DOC, { :argv => argv })
    rescue SystemExit => ex
      nil
    end
  end

  def test_size
    options = get_options(['arg'])
    assert_equal 16, options.size
  end
    
  def test_option
    options = get_options(['arg'])
    assert_equal ".svn,CVS,.bzr,.hg,.git", options['--exclude']
  end
    
  def test_values
    options = get_options(['arg'])
    assert !options['--help']
    assert !options['-h']
    assert !options['--version']
    assert !options['-v']
    assert !options['--verbose']
    assert !options['--quiet']
    assert !options['-q']
    assert !options['--repeat']
    assert !options['-r']
    assert_equal ".svn,CVS,.bzr,.hg,.git", options['--exclude']
    assert_equal "*.rb", options['--filename']
    assert !options['--select']
    assert !options['--ignore']
    assert !options['--show-source']
    assert !options['--statistics']
    assert !options['--count']
    assert !options['--benchmark']
    assert !options['--testsuite']
    assert !options['--doctest']
  end
end