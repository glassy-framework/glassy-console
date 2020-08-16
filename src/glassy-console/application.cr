require "./interfaces/output"
require "./command"
require "./argument_parser"

module Glassy::Console
  class Application
    getter output

    def initialize(@name : String, @output : Interfaces::Output, @commands : Array(Command))
    end

    def run(argv : Array(String)) : Void
      parser = ArgumentParser.new(argv, ["help"])
      arguments = parser.get_arguments
      cmd_name = arguments.shift?

      if cmd_name
        cmd = find_command(cmd_name)

        if cmd.nil?
          output.error("Command not found: #{cmd_name}")
        else
          if parser.get_bool_option("help")
            cmd.describe
          else
            run_command(cmd, argv)
          end
        end
      else
        validator = ArgumentValidator.new({
          "help" => {ArgumentValidator::ArgType::Option, false}
        })

        if validator.validate(parser)
          display_main_screen
        else
          @output.error(validator.error_message.not_nil!)
        end
      end
    end

    def find_command(cmd_name : String): Command?
      @commands.each do |cmd|
        if cmd.name == cmd_name
          return cmd
        end
      end

      return nil
    end

    def run_command(cmd : Command, argv : Array(String)) : Void
      new_argv = [] of String
      cmd_name_removed = false

      argv.each do |arg|
        if arg == cmd.name && !cmd_name_removed
          cmd_name_removed = true
        else
          new_argv << arg
        end
      end

      cmd.execute_arguments(new_argv)
    end

    def display_main_screen
      output.writeln(@name)
      output.writeln
      output.writeln("Usage:", :yellow)
      output.writeln("  command [options] [arguments]")
      output.writeln
      output.writeln("Options:", :yellow)
      output.display_two_columns [
        {"--help", "display help"}
      ]
      output.writeln
      output.writeln("Available commands:", :yellow)

      commands_by_prefix = make_commands_by_prefix
      prefixes = commands_by_prefix.keys.sort

      prefixes.each do |prefix|
        if prefix != ""
          output.writeln(" #{prefix}", :yellow)
        end
        commands = commands_by_prefix[prefix]
        columns = commands.sort_by {|c| c.name }.map do |command|
          {command.name, command.description}
        end
        output.display_two_columns(columns)
      end
    end

    def make_commands_by_prefix : Hash(String, Array(Command))
      group = Hash(String, Array(Command)).new

      @commands.each do |command|
        name_pieces = command.name.split(":")
        prefix = name_pieces.size > 1 ? name_pieces[0] : ""

        unless group.has_key?(prefix)
          group[prefix] = [] of Command
        end

        group[prefix] << command
      end

      group
    end
  end
end
