# glassy-console

[![CircleCI](https://circleci.com/gh/glassy-framework/glassy-console.svg?style=svg)](https://circleci.com/gh/glassy-framework/glassy-console)

Console commands for the glassy framework

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     glassy-console:
       github: glassy-framework/glassy-console
   ```

2. Run `shards install`

## Usage

We recommend using with the DI container, available in [glassy-kernel](https://github.com/glassy-framework/glassy-kernel).

Add the Console Bundle to your DI container:

```crystal
require "glassy-kernel"
require "glassy-console"
require "./commands/my_command"

class AppKernel < Glassy::Kernel::Kernel
  register_bundles [
    Glassy::Console::Bundle,
    MyAppBundle
  ]
end
```

Create your command:

```crystal
require "glassy-console"

class MyCommand < Glassy::Console::Command
  property name : String = "my:command"
  property description : String = "my description"

  @[Argument(name: "name", desc: "Name of the person")]
  @[Option(name: "fill", desc: "Fill or not?")]
  def execute(name : String, fill : Bool)
    output.writeln("name = #{name}")
    output.writeln("fill = #{fill}")
  end
end
```

Add to your service file (services.yml)

```yml
services:
  my_command:
    class: MyCommand
    kwargs:
      input: '@console_input'
      output: '@console_output'
    tag:
      - command
```

Now you can run setup your console application: 

```crystal
kernel = AppKernel.new
kernel.container.console_app.run(ARGV)
```

## Development

Always run crystal spec before submiting code

## Contributing

1. Fork it (<https://github.com/glassy-framework/glassy-console/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anderson Danilo](https://github.com/andersondanilo) - creator and maintainer
