require "./spec_helper"

class MyCommand < Glassy::Console::Command
  def name : String
    "my:command"
  end

  def description : String
    "my description"
  end

  @[Argument(name: "name", desc: "Name of the person")]
  @[Argument(name: "age", desc: "Age of the person")]
  @[Option(name: "show", desc: "Info of the show")]
  @[Option(name: "platform", desc: "The platform")]
  @[Option(name: "enabled", desc: "Is enabled")]
  def execute(name : String, show : String, age : Int, platform : Int?, enabled : Bool)
    output.writeln("name = #{name}")
    output.writeln("age = #{age}")
    output.writeln("show = #{show}")
    output.writeln("platform = #{platform}")
    output.writeln("enabled = #{enabled}")
  end

end

describe Glassy::Console::Command do
  it "execute arguments" do
    input = Glassy::Console::ArrayInput.new([] of String)
    output = Glassy::Console::ArrayOutput.new

    command = MyCommand.new(input, output)
    command.execute_arguments(["my name", "10", "--show", "help", "--platform", "2", "--enabled"])

    expected_response = [
      "name = my name",
      "age = 10",
      "show = help",
      "platform = 2",
      "enabled = true"
    ]

    output.items.should eq(expected_response)

    output.clear

    expected_response = <<-END
    Description:
      my description

    Usage:
      my:command [options] <name> <age>

    Options:
      --help            Display this help message
      --show=VALUE      Info of the show
      --platform=VALUE  The platform
      --enabled         Is enabled
    END

    command.describe

    output.buffer.should eq(expected_response + "\n")
  end
end
