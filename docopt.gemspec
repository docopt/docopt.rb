## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'
  s.required_ruby_version = '>= 1.8.7'
  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'docopt'
  s.version           = '0.5.0'
  s.date              = '2012-09-01'
  # s.rubyforge_project = 'docopt'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary = "A command line option parser, that will make you smile."
  s.description = "Isn't it awesome how `optparse` and other option parsers generate help and usage-messages based on your code?! Hell no!\nYou know what's awesome? It's when the option parser *is* generated based on the help and usage-message that you write in a docstring! That's what docopt does!"

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors = ["Blake Williams", "Vladimir Keleshev", "Alex Speller", "Nima Johari"]
  s.email = "code@shabbyrobe.org"
  s.homepage = "http://github.com/docopt/docopt.rb"
  s.license = 'MIT'
  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## This sections is only necessary if you have C extensions.
  # s.require_paths << 'ext'
  # s.extensions = %w[ext/extconf.rb]

  ## If your gem includes any executables, list them here.
  # s.executables = ["name"]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  # s.add_dependency('DEPNAME', [">= 1.1.0", "< 2.0.0"])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('json', "~> 1.6.5")

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE
    README.md
    Rakefile
    docopt.gemspec
    examples/any_options_example.rb
    examples/calculator.rb
    examples/counted_example.rb
    examples/example_options.rb
    examples/git_example.rb
    examples/naval_fate.rb
    examples/odd_even_example.rb
    examples/quick_example.rb
    lib/docopt.rb
    test/test_docopt.rb
    test/testee.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
