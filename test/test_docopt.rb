require 'test/unit'

class DocoptTest < Test::Unit::TestCase
  def setup
    $LOAD_PATH << File.dirname(__FILE__)
    load 'example.rb'
    @docopt = Docopt($DOC)
  end
    
  def test_size
    assert_equal 15, @docopt.size
  end
    
  def test_option
    assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt.option('--exclude').value
  end
    
  def test_unknown_option
    assert_raise(Docopt::UnknownOptionError) { @docopt.option('--other') }
    assert_raise(Docopt::UnknownOptionError) { @docopt.option('-o') }
  end
    
  def test_values
    assert_nil @docopt.value('--help')
    assert_nil @docopt.value('-h')
    assert_nil @docopt.value('--version')
    assert_nil @docopt.value('-v')
    assert_nil @docopt.value('--verbose')
    assert_nil @docopt.value('--quiet')
    assert_nil @docopt.value('-q')
    assert_nil @docopt.value('--repeat')
    assert_nil @docopt.value('-r')
    assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt.value('--exclude')
    assert_equal "*.rb", @docopt.value('--filename')
    assert_nil @docopt.value('--select')
    assert_nil @docopt.value('--ignore')
    assert_nil @docopt.value('--show-source')
    assert_nil @docopt.value('--statistics')
    assert_nil @docopt.value('--count')
    assert_nil @docopt.value('--benchmark')
    assert_nil @docopt.value('--testsuite')
    assert_nil @docopt.value('--doctest')
  end
    
  def test_hash_like_access
    assert_nil @docopt['--help']
    assert_nil @docopt['-h']
    assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt['--exclude']
    assert_raise(Docopt::UnknownOptionError) { @docopt['--fakeoption'] }
    assert_raise(Docopt::UnknownOptionError) { @docopt['-f'] }      
  end
    
  def test_symbol_access
    assert_nil @docopt[:help]
    assert_nil @docopt[:h]
    assert_equal ".svn,CVS,.bzr,.hg,.git", @docopt[:exclude]
    assert_raise(Docopt::UnknownOptionError) { @docopt[:fakeoption] }
    assert_raise(Docopt::UnknownOptionError) { @docopt[:f] }      
  end
end