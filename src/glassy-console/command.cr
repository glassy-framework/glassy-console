require "./annotations/argument"
require "./annotations/option"
require "./argument_parser"

module Glassy::Console
  abstract class Command
    alias Argument = Annotations::Argument
    alias Option = Annotations::Option

    macro inherited
      macro method_added(method)
        {% verbatim do %}
          {% if "execute" == method.name %}
            def execute_arguments(args : Array(String))
              parser = Glassy::Console::ArgumentParser.new(args, [
                {% for marg in method.args %}
                  {% if marg.restriction.types.any?{|r| r.stringify.includes?("Bool")} %}
                    "{{marg.name}}",
                  {% end %}
                {% end %}
                "help"
              ])

              arguments = parser.get_arguments()

              {% for marg in method.args %}
                {% type_modifier = "" %}

                {% if marg.restriction.stringify.includes?("Int") %}
                  {% type_modifier = ".to_i" %}
                {% end %}

                {% nullable = marg.restriction.types.any?{|r| r.stringify.includes?("Nil")} %}
                {% boolean = marg.restriction.types.any?{|r| r.stringify.includes?("Bool")} %}

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
                      val_{{marg.name}} = "1" == tmp_val_{{marg.name}}{{type_modifier.id}}
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
          {% end %}
        {% end %}
      end
    end
  end
end
