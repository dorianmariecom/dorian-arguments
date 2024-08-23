require "dorian/to_struct"
require "bigdecimal"
require "bigdecimal/util"
require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/enumerable"

class Dorian
  class Arguments
    attr_reader :definition

    BOOLEAN = "boolean"
    STRING = "string"
    NUMBER = "number"
    INTEGER = "integer"
    DECIMAL = "decimal"

    DEFAULT_MULTIPLE = false
    DEFAULT_ALIASES = []
    DEFAULT_TYPE = BOOLEAN

    TYPES = [BOOLEAN, STRING, NUMBER, INTEGER, DECIMAL]

    DEFAULTS = {
      BOOLEAN => "false",
      STRING => "",
      NUMBER => "0",
      INTEGER => "0",
      DECIMAL => "0"
    }

    MATCHES = {
      BOOLEAN => /^(true|false)$/i,
      STRING => /^.+$/i,
      NUMBER => /^[0-9.]+$/i,
      INTEGER => /^[0-9]+$/i,
      DECIMAL => /^[0-9.]+$/i
    }

    BOOLEANS = { "true" => true, "false" => false }

    def initialize(**definition)
      @definition = definition
    end

    def self.parse(...)
      new(...).parse
    end

    def parse
      arguments = ARGV
      options = {}
      files = []

      definition.each do |key, value|
        type, default, aliases = normalize(value)

        keys = ([key] + aliases).map(&:to_s).map(&:parameterize)
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
                elsif arguments[index + 1].to_s =~ MATCHES.fetch(type)
                  indexes << index + 1

                  arguments[index + 1]
                else
                  default
                end
              end
            end
            .reject(&:nil?)

        indexes.sort.reverse.uniq.each { |index| arguments.delete_at(index) }

        values = [default] if values.empty?
        values = values.map { |value| cast(type, value) }
        values = values.first unless values.many?
        options[key] = values
      end

      files = arguments.select { |argument| File.exist?(argument) }

      arguments -= files

      { arguments:, options:, files:, help: }.to_deep_struct
    end

    def cast(type, value)
      if type == BOOLEAN
        BOOLEANS.fetch(value.downcase)
      elsif type == INTEGER
        value.to_i
      elsif type == DECIMAL || type == NUMBER
        value.to_d
      else
        value
      end
    end

    def help
      message = "USAGE: #{$PROGRAM_NAME}\n"

      message += "\n" if definition.any?

      definition.each do |key, value|
        type, default, aliases = normalize(value)

        keys_message =
          ([key] + aliases)
            .map(&:to_s)
            .map(&:parameterize)
            .map { |key| key.size == 1 ? "-#{key}" : "--#{key}" }
            .join("|")

        message +=
          "  #{keys_message} #{type.upcase}, default: #{cast(type, default).inspect}\n"
      end

      message
    end

    def normalize(value)
      if value.is_a?(Hash)
        type = value[:type]&.to_s || DEFAULT_TYPE
        default = value[:default]&.to_s || DEFAULTS.fetch(type)
        aliases =
          Array.wrap(
            value[:alias]&.to_s || value[:aliases]&.map(&:to_s) ||
              DEFAULT_ALIASES
          )
      else
        type = value.to_s
        default = DEFAULTS.fetch(type)
        aliases = DEFAULT_ALIASES
      end

      [type, default, aliases]
    end
  end
end
