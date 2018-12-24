require "./lib/attr_sequence/version"

Gem::Specification.new do |gem|
  gem.name        = "attr_sequence"
  gem.version     = AttrSequence::Version::Compact
  gem.summary     = AttrSequence::Version::Summary
  gem.description = AttrSequence::Version::Description
  gem.authors     = AttrSequence::Version::Author
  gem.email       = AttrSequence::Version::Email
  gem.homepage    = AttrSequence::Version::Homepage
  gem.license     = AttrSequence::Version::License
  gem.metadata    = AttrSequence::Version::Metadata
  gem.platform    = Gem::Platform::RUBY

  gem.required_ruby_version = '>= 2.3'
  gem.require_paths = ["lib"]
  gem.files = Dir[
    "{lib}/**/*",
    "MIT-LICENSE.md",
    "CHANGELOG.md",
    "README.md"
  ]

  gem.add_runtime_dependency 'activerecord', '>= 5.1.4'
  gem.add_runtime_dependency 'activesupport', '>= 5.1.4'
end
