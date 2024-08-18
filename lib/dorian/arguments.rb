require "dorian/to_struct"

class Dorian
  class Arguments
    attr_reader :definition

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
        if value.is_a?(Hash)
          type = value[:type] || "boolean"
          default = value[:default] || nil
          aliases = value[:alias] || value[:aliases] || []
        else
          type = value
          default = nil
          aliases = []
        end

        argument = arguments.detect do |argument|
          argument = argument.split("=").first

          ([key] + aliases).any? do |key|
            argument == "--#{key.to_s}" || argument == "-#{key.to_s}"
          end
        end

        if argument&.include?("=")
          value = argument.split("=", 2)
        else
          value = default
        end

        if type == "boolean"
          if value.to_s.downcase == "true" || value == "1"
            value = true
          elsif value.to_s.downcase == "false" || value == "0"
            value = false
          elsif value.nil?
            value = false
          else
            abort "#{value} not supported"
          end
        else
          raise NotImplementedError
        end

        arguments -= [argument]

        options[key] = value
      end

      files = arguments.select { |argument| File.exist?(argument) }

      arguments -= files

      [arguments, options.to_struct, files]
    end
  end
end
