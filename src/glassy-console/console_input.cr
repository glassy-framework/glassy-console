require "./interfaces/input"

module Glassy::Console
  class ConsoleInput
    include Interfaces::Input

    def readln() : String?
      gets
    end
  end
end
