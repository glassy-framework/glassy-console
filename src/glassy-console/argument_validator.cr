require "./argument_parser"

module Glassy::Console
  class ArgumentValidator
    enum ArgType
      Argument
      Option
    end

    alias ArgRule = Tuple(ArgType, Bool)

    property error_message : String?

    def initialize(@rules : Hash(String, ArgRule))
    end

    def validate (argv : Array(String)) : Bool
      parser = ArgumentParser.new(argv, [] of String)
      validate(parser)
    end

    def validate (parser : ArgumentParser) : Bool
      @error_message = nil

      # validate argument quantity
      argument_names = get_argument_names
      if parser.get_arguments.size > argument_names.size
        message = "Too many arguments"
        if argument_names.size > 0
          expected = argument_names.map {|n| "\"#{n}\""}.join(", ")
          message += ", expected arguments #{expected}"
        end
        @error_message = message
        return false
      end

      # validate required arguments
      arguments = parser.get_arguments
      idx = 0

      get_arg_rules.each do |name, rule|
        value = arguments[idx]?

        if rule[1] && (value.nil? || value.size == 0)
          @error_message = "The argument #{name} is required"
          return false
        end

        idx += 1
      end

      # validate not existing options
      parser.get_option_names.each do |opt_name|
        unless has_option?(opt_name)
          @error_message = "The option --#{opt_name} does not exists"
          return false
        end
      end

      # validate required options
      @rules.each do |opt_name, rule|
        if ArgType::Option == rule[0] && rule[1]
          value = parser.get_option(opt_name)

          if value.nil? || value.size == 0
            @error_message = "The option --#{opt_name} is required"
            return false
          end
        end
      end


      return true
    end

    def has_option?(name : String) : Bool
      unless @rules.has_key?(name)
        return false
      end

      rule = @rules[name]

      return rule[0] == ArgType::Option
    end

    def get_argument_names : Array(String)
      names = [] of String

      @rules.each do |name, rule|
        if rule[0] == ArgType::Argument
          names << name
        end
      end

      names
    end

    def get_arg_rules : Hash(String, ArgRule)
      @rules.select do |key, rule|
        rule[0] == ArgType::Argument
      end
    end
  end
end
