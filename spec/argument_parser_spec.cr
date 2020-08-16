require "./spec_helper"

alias ArgumentParser = Glassy::Console::ArgumentParser

describe ArgumentParser do
  it "get arguments" do
    parser = ArgumentParser.new(["app:console", "--show", "help"], [] of String)
    parser.get_arguments.should eq(["app:console"])

    parser = ArgumentParser.new(["app:console", "--show=help"], [] of String)
    parser.get_arguments.should eq(["app:console"])

    parser = ArgumentParser.new(["app:console", "--show", "help"], ["show"])
    parser.get_arguments.should eq(["app:console", "help"])
  end

  it "get option" do
    parser = ArgumentParser.new(["app:console", "--show", "help"], [] of String)
    parser.get_option("show").should eq("help")

    parser = ArgumentParser.new(["app:console", "--show=help"], [] of String)
    parser.get_option("show").should eq("help")

    parser = ArgumentParser.new(["app:console", "--show=\"help\""], [] of String)
    parser.get_option("show").should eq("help")

    parser = ArgumentParser.new(["app:console", "--show", "'help'"], [] of String)
    parser.get_option("show").should eq("help")

    parser = ArgumentParser.new(["app:console", "--show", "'help'"], ["show"])
    parser.get_option("show").should eq("1")
  end
end
