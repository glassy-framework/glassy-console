require "./spec_helper"

alias ArgumentValidator = Glassy::Console::ArgumentValidator
alias ArgType = Glassy::Console::ArgumentValidator::ArgType

describe ArgumentValidator do
  it "validate arguments" do
    validator = ArgumentValidator.new({
      "command" => {ArgType::Argument, true},
      "other"   => {ArgType::Argument, false},
    })

    validator.validate([] of String).should eq(false)
    validator.error_message.should eq("The argument command is required")

    validator.validate(["hello"]).should eq(true)
    validator.validate(["hello", "second"]).should eq(true)

    validator.validate(["hello", "second", "third"]).should eq(false)
    validator.error_message.should eq("Too many arguments, expected arguments \"command\", \"other\"")
  end

  it "validate options" do
    validator = ArgumentValidator.new({
      "port" => {ArgType::Option, true},
      "host" => {ArgType::Option, false},
    })

    validator.validate([] of String).should eq(false)
    validator.error_message.should eq("The option --port is required")

    validator.validate(["--port", "80"] of String).should eq(true)

    validator.validate(["--port", "80", "--doing"] of String).should eq(false)
    validator.error_message.should eq("The option --doing does not exists")

    validator = ArgumentValidator.new({
      "port"    => {ArgType::Option, true},
      "enabled" => {ArgType::Option, true},
    })

    parser = Glassy::Console::ArgumentParser.new(["--port", "80"], ["enabled"])
    validator.validate(parser).should eq(true)
  end

  it "accept help as a value" do
    validator = ArgumentValidator.new({
      "port" => {ArgType::Option, true},
      "host" => {ArgType::Option, false},
    })

    parser = Glassy::Console::ArgumentParser.new(["--port", "help", "--host"], ["help"])

    validator.validate(parser).should eq(true)
  end
end
