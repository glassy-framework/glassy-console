require "../src/glassy-console"

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

input = Glassy::Console::ConsoleInput.new
output = Glassy::Console::ConsoleOutput.new

command = MyCommand.new(input, output)

application = Glassy::Console::Application.new(
  "My app",
  output,
  [command] of Glassy::Console::Command
)

application.run(ARGV)
