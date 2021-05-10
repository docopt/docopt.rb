require 'test/unit'
require 'pathname'
require 'docopt'

class DocoptTest < Test::Unit::TestCase

  TOPDIR = Pathname.new(__FILE__).dirname.dirname

  def test_docopt_reference_testcases
    puts
    assert system('python', "test/language_agnostic_tester.py", "test/testee.rb", chdir: TOPDIR)
  end

  def test_exit_success_on_help
    exception = assert_raises(Docopt::Exit) do
      Docopt.docopt("Usage: mytool -a", :argv => ["--help"])
    end

    assert !exception.error?
  end

  def test_exit_success_on_version
    exception = assert_raises(Docopt::Exit) do
      Docopt.docopt("Usage: mytool -a", :version => "1.2.3", :argv => ["--version"])
    end

    assert !exception.error?
  end

  def test_exit_failure_on_unknown_option
    exception = assert_raises(Docopt::Exit) do
      Docopt.docopt("Usage: mytool -a", :argv => ["--foo"])
    end

    assert exception.error?
  end
end
