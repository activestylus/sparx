require_relative 'lib/sparx/version'

Gem::Specification.new do |s|
  s.name        = 'sparx'
  s.version     = Sparx::VERSION
  s.summary     = "A friendly markup language for the modern web"
  s.description = "Sparx is a powerful, semantic markup language that generates clean HTML without the limitations of Markdown"
  s.authors     = ["Steven Garcia"]
  s.email       = 'stevendgarcia@gmail.com'
  s.files       = Dir[
    'lib/**/*.rb',
    'syntaxes/**/*',           # Include syntax files
    'themes/**/*',             # Include theme files
    'editors/**/*',            # Include editor configs
    'bin/sparx',
    'README.md',
    'LICENSE'
  ]
  s.executables = ['sparx']
  s.homepage    = 'https://github.com/activestylus/sparx'
  s.license     = 'MIT'
  s.metadata    = {
    #{}"documentation_uri" => "https://sparx.dev/docs",
    "homepage_uri"      => "https://github.com/activestylus/sparx",
    "source_code_uri"   => "https://github.com/activestylus/sparx",
    "changelog_uri"     => "https://github.com/activestylus/sparx/blob/main/CHANGELOG.md"
  }
  
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_runtime_dependency "listen", "~> 3.0"
end