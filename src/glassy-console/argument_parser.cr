module Glassy::Console
  class ArgumentParser
    def initialize(@args : Array(String), @bool_args_names : Array(String))
    end

    def get_arguments : Array(String)
      last_arg = ""

      @args.reject { |arg|
        return_value = is_option(arg) || is_option_value(arg, last_arg)
        last_arg = arg
        return_value
      }.map { |arg| parse_value(arg) }
    end

    def is_option(name : String) : Bool
        name.starts_with?("--")
    end

    def is_option_value(value : String, last_name : String)
      if is_option(last_name) && !is_boolean_option(last_name)
        return true
      end

      return false
    end

    def is_boolean_option(name : String) : Bool
      if !is_option(name)
        return false
      end

      real_name = get_real_option_name(name)

      if @bool_args_names.includes?(real_name)
        return true
      end

      return false
    end

    def get_real_option_name(name : String) : String
      name.sub("--", "").sub(/=.*$/, "")
    end

    def get_option (name : String): String?
      return_next_arg = false

      @args.each do |arg|
        if return_next_arg
          return parse_value(arg)
        end

        if is_option(arg) && cmp_option(name, arg)
          if is_boolean_option(arg)
            return "1"
          else
            pieces = arg.split("=")

            if pieces.size > 1
              first_piece = pieces.shift()
              return parse_value(pieces.join("="))
            else
              return_next_arg = true
            end
          end
        end
      end

      return nil
    end

    def cmp_option(name1 : String, name2 : String)
      get_real_option_name(name1) == get_real_option_name(name2)
    end

    def parse_value(value : String)
      value.gsub(/^'(.+)'$/, "\\1").gsub(/^"(.+)"$/, "\\1")
    end
  end
end
