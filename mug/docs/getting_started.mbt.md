# Getting Started with Mug

This guide will help you create your first CLI application using the Mug framework.

## Prerequisites

- MoonBit CLI installed
- Basic understanding of MoonBit syntax

## Creating Your First CLI

### 1. Initialize a New Project

```bash
moon new mycli
cd mycli
```

### 2. Add Mug Dependency

```bash
moon add colmugx/mug
```

### 3. Create Your Main File

Edit `src/main/main.mbt`:

```mbt
pub fn main {
  let app = @app.App::new("mycli", "My first CLI tool")
  app.version("1.0.0")

  // Add commands
  let hello = HelloCommand::{}
  app.add_command(hello)

  // Execute
  let args = @sys.argv.get_view()
  app.execute(args)
}

pub struct HelloCommand {}

impl TCommand for HelloCommand with name(_) {
  "hello"
}

impl TCommand for HelloCommand with description(_) {
  "Say hello to the world"
}

impl TCommand for HelloCommand with execute(self, args) {
  println("Hello, World!")
}

impl HelpPrinter for HelloCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
```

### 4. Build and Run

```bash
moon run
```

Test your CLI:

```bash
moon run -- hello
# Output: Hello, World!

moon run -- --help
# Output: Help information
```

## Understanding the Structure

### App

The `App` struct is the main entry point:

```mbt
let app = @app.App::new(name, description)
```

**Methods:**
- `version(version: String)` - Set application version
- `add_command(command: &TCommand)` - Register a command
- `execute(args: ArrayView[String])` - Run the application

### Commands

Commands implement the `TCommand` trait:

```mbt
pub(open) trait TCommand: HelpPrinter {
  execute(Self, Array[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
}
```

**Required implementations:**
- `name(_)` - Command name (e.g., "hello")
- `description(_)` or `description(self)` - Command description
- `execute(self, args)` - Command logic
- `print_usage(self)` - Help text (from `HelpPrinter` trait)

## Next Steps

- **Adding Arguments**: Learn how to handle command arguments
- **Flag Support**: Add flags and options to your commands
- **Internationalization**: Add multiple language support
- **Advanced Features**: Explore subcommands and terminal UI

See the [Command Guide](commands.md) for more details on creating commands.
