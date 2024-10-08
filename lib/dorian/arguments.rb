# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

class Dorian
  class Arguments
    attr_reader :definition

    BOOLEAN = "boolean"
    STRING = "string"
    NUMBER = "number"
    INTEGER = "integer"
    DECIMAL = "decimal"

    DEFAULT_MULTIPLE = false
    DEFAULT_ALIASES = [].freeze
    DEFAULT_TYPE = BOOLEAN

    TYPES = [BOOLEAN, STRING, NUMBER, INTEGER, DECIMAL].freeze

    DEFAULT = nil

    MATCHES = {
      BOOLEAN => /^(true|false)$/i,
      STRING => /^.+$/i,
      NUMBER => /^[0-9.]+$/i,
      INTEGER => /^[0-9]+$/i,
      DECIMAL => /^[0-9.]+$/i
    }.freeze

    BOOLEANS = { "true" => true, "false" => false }.freeze

    def initialize(**definition)
      @definition = definition
    end

    def self.parse(...)
      new(...).parse
    end

    def parse
      arguments = ARGV
      options = {}

      definition.each do |key, value|
        type, default, aliases = normalize(value)

        keys = ([key] + aliases).map(&:to_s).map { |key| parameterize(key) }
        keys = keys.map { |key| ["--#{key}", "-#{key}"] }.flatten

        indexes = []

        values =
          arguments
            .map
            .with_index do |argument, index|
              if keys.include?(argument.split("=").first)
                indexes << index

                if argument.include?("=")
                  argument.split("=", 2).last
                elsif arguments[index + 1].to_s&.match?(MATCHES.fetch(type))
                  indexes << (index + 1)

                  arguments[index + 1]
                elsif type == BOOLEAN
                  "true"
                else
                  default
                end
              end
            end
            .compact

        indexes.sort.reverse.uniq.each { |index| arguments.delete_at(index) }

        values = [default] if values.empty?
        values = values.map { |value| cast(type, value) }
        values = values.first unless many?(values)
        options[key] = values
      end

      files = arguments.select { |argument| File.exist?(argument) }

      arguments -= files

      options = Struct.new(*options.keys).new(*options.values)

      Struct.new(:arguments, :options, :files, :help).new(
        arguments,
        options,
        files,
        help
      )
    end

    def cast(type, value)
      if value.nil?
        nil
      elsif type == BOOLEAN
        BOOLEANS.fetch(value.downcase)
      elsif type == INTEGER
        value.to_i
      elsif [DECIMAL, NUMBER].include?(type)
        value.to_d
      else
        value
      end
    end

    def help
      message = "USAGE: #{File.basename($PROGRAM_NAME)}\n"

      message += "\n" if definition.any?

      definition.each do |key, value|
        type, default, aliases = normalize(value)

        keys_message =
          ([key] + aliases)
            .map(&:to_s)
            .map { |key| parameterize(key) }
            .map { |key| key.size == 1 ? "-#{key}" : "--#{key}" }
            .join("|")

        message +=
          "  #{keys_message} #{type.upcase}, default: #{cast(type, default).inspect}\n"
      end

      message
    end

    def many?(array)
      array.size > 1
    end

    def parameterize(string, separator: "-")
      string
        .to_s
        .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
        .downcase
        .gsub(/[^a-z0-9]+/, separator)
        .gsub(/^#{separator}+|#{separator}+$/, "")
    end

    def normalize(value)
      if value.is_a?(Hash)
        type = value[:type]&.to_s || DEFAULT_TYPE
        default = value[:default]&.to_s || DEFAULT
        aliases =
          Array(
            value[:alias]&.to_s || value[:aliases]&.map(&:to_s) ||
              DEFAULT_ALIASES
          )
      else
        type = value.to_s
        default = DEFAULT
        aliases = DEFAULT_ALIASES
      end

      [type, default, aliases]
    end
  end
end
