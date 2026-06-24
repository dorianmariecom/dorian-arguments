# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "dorian-arguments"
  s.version = File.read("VERSION").strip
  s.summary = "parses arguments"
  s.description = "Small command-line argument parser used by Dorian tools."
  s.authors = ["Dorian Marié"]
  s.email = "dorian@dorianmarie.com"
  s.files = %w[
    VERSION
    lib/dorian-arguments.rb
    lib/dorian/arguments.rb
    bin/arguments
  ]
  s.executables << "arguments"
  s.homepage = "https://github.com/dorianmariecom/dorian-arguments"
  s.license = "MIT"
  s.metadata = { "rubygems_mfa_required" => "true" }
  s.add_dependency "bigdecimal", ">= 3.1", "< 5"
  s.required_ruby_version = ">= 4.0"
end
