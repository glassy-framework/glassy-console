require "./interfaces/input"

module Glassy::Console
  class ArrayInput
    include Interfaces::Input

    def initialize (@items : Array(String))
    end

    def readln() : String?
      @items.shift()
    end
  end
end
