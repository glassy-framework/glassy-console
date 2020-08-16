require "./interfaces/output"

module Glassy::Console
  class ConsoleOutput
    include Interfaces::Output

    def writeln(text : String = "") : Void
      puts text
    end

    def write(text : String) : Void
      print text
    end
  end
end
