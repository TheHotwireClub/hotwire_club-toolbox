require_relative "lib/hotwire_club/toolbox/version"

Gem::Specification.new do |spec|
  spec.name        = "hotwire_club-toolbox"
  spec.version     = HotwireClub::Toolbox::VERSION
  spec.authors     = [ "Julian Rubisch" ]
  spec.email       = [ "julian@julianrubisch.at" ]
  spec.homepage    = "https://github.com/TheHotwireClub/hotwire_club-toolbox"
  spec.summary     = "A collection of loosely connected Hotwire and Rails tools and techniques."
  spec.description = "HotwireClub::Toolbox is a Rails engine that packages a collection of " \
                     "loosely connected Hotwire and Rails tools and techniques, starting with " \
                     "an optimistic-UI form builder for Turbo."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,docs,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3"
  spec.add_dependency "turbo-rails", "~> 2.0"
end
