require "./annotations/argument"
require "./annotations/option"
require "./argument_parser"
require "./argument_validator"
require "./interfaces/input"
require "./interfaces/output"

module Glassy::Console
  abstract class Command
    alias Argument = Annotations::Argument
    alias Option = Annotations::Option
    alias ArgumentValidator = Glassy::Console::ArgumentValidator
    alias Input = Glassy::Console::Interfaces::Input
    alias Output = Glassy::Console::Interfaces::Output

    property input : Input
    property output : Output

    def initialize(@input : Input, @output : Output)
    end

    abstract def name : String
    abstract def description : String
    abstract def execute_arguments(args : Array(String)) : Void
    abstract def get_metadata : Array(Hash(String, String))

    def describe
      output.writeln("Description:", :yellow)
      output.writeln("  #{description}")
      output.writeln

      args_text = get_metadata
        .select { |item| item["type"] == "argument" }
        .map { |item| "<#{item["name"]}>" }
        .join(" ")

      output.writeln("Usage:", :yellow)
      output.writeln("  #{name} [options] #{args_text}")
      output.writeln

      option_texts = [
        {"--help", "Display this help message"},
      ]
      get_metadata.each do |item|
        if item["type"] == "option"
          arg_name = "--#{item["name"]}"
          if item["boolean"] == "0"
            arg_name += "=VALUE"
          end
          option_texts << {arg_name, item["description"]}
        end
      end

      output.writeln("Options:", :yellow)
      output.display_two_columns(option_texts)
    end

    macro inherited
      macro method_added(method)
        {% verbatim do %}
          {% if "execute" == method.name %}
            def execute_arguments(args : Array(String)) : Void
              parser = Glassy::Console::ArgumentParser.new(args, [
                {% for marg in method.args %}
                  {% if marg.restriction.types.any? { |r| r.stringify.includes?("Bool") } %}
                    "{{marg.name}}",
                  {% end %}
                {% end %}
                "help"
              ])

              validator = ArgumentValidator.new({
                {% for ann, idx in method.annotations(Argument) %}
                  {% nullable = false %}
                  {% for marg in method.args %}
                    {% if marg.name == ann[:name].id %}
                      {% nullable = marg.restriction.types.any? { |r| r.stringify.includes?("Nil") } %}
                    {% end %}
                  {% end %}
                  "{{ann[:name].id}}" => {ArgumentValidator::ArgType::Argument, {{ nullable ? "false".id : "true".id }} },
                {% end %}
                {% for ann, idx in method.annotations(Option) %}
                  {% nullable = false %}
                  {% for marg in method.args %}
                    {% if marg.name == ann[:name].id %}
                      {% nullable = marg.restriction.types.any? { |r| r.stringify.includes?("Nil") } %}
                    {% end %}
                  {% end %}
                  "{{ann[:name].id}}" => {ArgumentValidator::ArgType::Option, {{ nullable ? "false".id : "true".id }} },
                {% end %}
              })

              unless validator.validate(parser)
                output.error(validator.error_message.not_nil!)
                return
              end

              arguments = parser.get_arguments()

              {% for marg in method.args %}
                {% type_modifier = "" %}

                {% if marg.restriction.stringify.includes?("Int") %}
                  {% type_modifier = ".to_i" %}
                {% end %}

                {% nullable = marg.restriction.types.any? { |r| r.stringify.includes?("Nil") } %}
                {% boolean = marg.restriction.types.any? { |r| r.stringify.includes?("Bool") } %}

                {% for ann, idx in method.annotations(Argument) %}
                  {% if marg.name == ann[:name].id %}
                    {% if nullable %}
                      val_{{marg.name}} = arguments[{{idx}}]? ? arguments[{{idx}}]{{type_modifier.id}} : nil
                    {% else %}
                      val_{{marg.name}} = arguments[{{idx}}]{{type_modifier.id}}
                    {% end %}
                  {% end %}
                {% end %}
                {% for ann, idx in method.annotations(Option) %}
                  {% if marg.name == ann[:name].id %}
                    tmp_val_{{marg.name}} = parser.get_option({{ann[:name]}})

                    {% if boolean %}
                      val_{{marg.name}} = parser.get_bool_option({{ann[:name]}})
                    {% elsif nullable %}
                      val_{{marg.name}} = tmp_val_{{marg.name}} ? tmp_val_{{marg.name}}{{type_modifier.id}} : nil
                    {% else %}
                      val_{{marg.name}} = tmp_val_{{marg.name}} ? tmp_val_{{marg.name}}{{type_modifier.id}} : ""{{type_modifier.id}}
                    {% end %}
                  {% end %}
                {% end %}
              {% end %}


              execute(
                {% for marg in method.args %}
                  {{marg.name}}: val_{{marg.name}},
                {% end %}
              )
            end

            def get_metadata : Array(Hash(String, String))
              return [
                {% for ann, idx in method.annotations(Argument) %}
                  {% for marg in method.args %}
                    {% if marg.name == ann[:name].id %}
                      {% nullable = marg.restriction.types.any? { |r| r.stringify.includes?("Nil") } %}
                      {% boolean = marg.restriction.types.any? { |r| r.stringify.includes?("Bool") } %}
                      {
                        "name" => {{ann[:name]}},
                        "type" => "argument",
                        "description" => "{{ann[:desc].id}}",
                        "boolean" => "{{boolean ? 1 : 0}}",
                        "nullable" => "{{nullable ? 1 : 0}}",
                      },
                    {% end %}
                  {% end %}
                {% end %}
                {% for ann, idx in method.annotations(Option) %}
                  {% for marg in method.args %}
                    {% if marg.name == ann[:name].id %}
                      {% nullable = marg.restriction.types.any? { |r| r.stringify.includes?("Nil") } %}
                      {% boolean = marg.restriction.types.any? { |r| r.stringify.includes?("Bool") } %}
                      {
                        "name" => {{ann[:name]}},
                        "type" => "option",
                        "description" => "{{ann[:desc].id}}",
                        "boolean" => "{{boolean ? 1 : 0}}",
                        "nullable" => "{{nullable ? 1 : 0}}",
                      },
                    {% end %}
                  {% end %}
                {% end %}
              ] of Hash(String, String)
            end
          {% end %}
        {% end %}
      end
    end
  end
end
