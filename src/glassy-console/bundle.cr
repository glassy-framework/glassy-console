require "glassy-kernel"

module Glassy::Console
  class Bundle < Glassy::Kernel::Bundle
    SERVICES_PATH = "#{__DIR__}/config/services.yml"
  end
end
