require 'test/unit'
require 'stringio'

class DocoptRbTest < Test::Unit::TestCase
  def setup
    orig_stdout, orig_stderr = $stdout, $stderr
    $stdout, $stderr = StringIO.new, StringIO.new
    load File.expand_path('../../examples/example_options.rb', __FILE__)
  ensure
    $stdout, $stderr = orig_stdout, orig_stderr
  end

  def get_options(argv=[])
    begin
      Docopt.docopt($DOC, { :argv => argv })
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
    assert_equal "*.rb", options['--file']
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