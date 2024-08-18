# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "dorian-arguments"
  s.version = "0.0.1"
  s.summary = "parses arguments"
  s.description = s.summary
  s.authors = ["Dorian Marié"]
  s.email = "dorian@dorianmarie.com"
  s.files = ["lib/dorian-arguments.rb", "lib/dorian/arguments.rb"]
  s.homepage = "https://github.com/dorianmariecom/dorian-arguments"
  s.license = "MIT"
  s.metadata = { "rubygems_mfa_required" => "true" }
  s.add_dependency "dorian-to_struct"
end
