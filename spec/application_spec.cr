require "./spec_helper"
require "colorize"

class MyCommand < Glassy::Console::Command
  def name : String
    "my:command"
  end

  def description : String
    "my description"
  end

  @[Argument(name: "name", desc: "Name of the person")]
  def execute(name : String)
    output.writeln("name = #{name}")
  end
end

describe Glassy::Console::Command do
  it "execute arguments" do
    input = Glassy::Console::ArrayInput.new([] of String)
    output = Glassy::Console::ArrayOutput.new
    command = MyCommand.new(input, output)
    application = Glassy::Console::Application.new(
      "My app",
      output,
      [command, command] of Glassy::Console::Command
    )

    application.run([] of String)

    expected_response = <<-END
    My app

    Usage:
      command [options] [arguments]

    Options:
      --help  display help

    Available commands:
     my
      my:command  my description
      my:command  my description
    END

    output.buffer.should eq(expected_response + "\n")
  end
end
