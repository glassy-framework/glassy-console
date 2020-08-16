require "./interfaces/output"

module Glassy::Console
  class ArrayOutput
    include Interfaces::Output

    getter buffer

    def initialize ()
      @buffer = ""
    end

    def writeln(text : String = "") : Void
      @buffer += "#{text}\n"
    end

    def write(text : String) : Void
      @buffer += "#{text}"
    end

    def items : Array(String)
      @buffer.rstrip("\n").split("\n")
    end

    def clear
      @buffer = ""
    end

    def colorize(text, fore : Symbol, back : Symbol? = nil): String
      text
    end
  end
end
