require "./spec_helper"

class MyCommand < Glassy::Console::Command

  @[Argument(name: "name", desc: "Name of the person")]
  @[Argument(name: "age", desc: "Age of the person")]
  @[Option(name: "show", desc: "Info of the show")]
  @[Option(name: "platform", desc: "The platform")]
  @[Option(name: "enabled", desc: "Is enabled")]
  def execute(name : String, show : String, age : Int, platform : Int?, enabled : Bool)
    "name = #{name},\n" +
    "age = #{age},\n" +
    "show = #{show},\n" +
    "platform = #{platform},\n" +
    "enabled = #{enabled}"
  end

end

describe Glassy::Console::Command do
  it "execute arguments" do
    command = MyCommand.new
    response = command.execute_arguments(["my name", "10", "--show", "help", "--platform", "2", "--enabled"])
    expected_response = <<-END
    name = my name,
    age = 10,
    show = help,
    platform = 2,
    enabled = true
    END

    response.should eq(expected_response)
  end
end
