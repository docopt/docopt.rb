require 'rake/testtask'
require 'test/unit'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
end
