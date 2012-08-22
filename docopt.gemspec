# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "docopt"
  s.version = "0.5.0"
  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"
  s.platform    = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.license     = 'MIT'
  s.authors = ["Blake Williams", "Vladimir Keleshev", "Alex Speller"]
  s.email = "code@shabbyrobe.org"
  s.date = "2012-08-20"
  s.description = "A command line option parser, that will make you smile. Isn't it awesome how `optparse` and other option parsers generate help and usage-messages based on your code?! Hell no!  You know what's awesome? It's when the option parser *is* generated based on the help and usage-message that you write in a docstring!"
  s.files = ["README.md", "LICENSE-MIT", "example.rb", "lib/docopt.rb"]
  s.homepage = "http://github.com/docopt/docopt.rb"
  s.summary = "A command line option parser, that will make you smile."
end
