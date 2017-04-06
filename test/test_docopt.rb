require 'test/unit'
require 'pathname'

class DocoptTest < Test::Unit::TestCase

  TOPDIR = Pathname.new(__FILE__).dirname.dirname

  def test_docopt_reference_testcases
    puts
    assert system('python', "test/language_agnostic_tester.py", "test/testee.rb", chdir: TOPDIR)
  end
end
