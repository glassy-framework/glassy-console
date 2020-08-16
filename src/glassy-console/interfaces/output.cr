require "colorize"

module Glassy::Console::Interfaces
  module Output
    abstract def writeln(text : String = "") : Void
    abstract def write(text : String) : Void

    def writeln(text : String, fore_color : Symbol) : Void
      writeln(colorize(text, fore_color))
    end

    def write(text : String, fore_color : Symbol) : Void
      write(colorize(text, fore_color))
    end

    def error(text : String) : Void
      writeln(colorize(text, :white, :red))
    end

    def colorize(text, fore : Symbol, back : Symbol? = nil): String
      result = text.colorize.fore(fore)

      if back
        result.back(back)
      end

      result.to_s
    end

    def display_two_columns(items : Array(Tuple(String, String)))
      first_size = items.reduce(0) do |max, item|
        item[0].size > max ? item[0].size : max
      end

      items.each do |item|
        write("  #{item[0].ljust(first_size)}", :green)
        writeln("  #{item[1]}")
      end
    end
  end
end
