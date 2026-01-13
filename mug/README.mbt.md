# Mug - CLI Framework for MoonBit

A flexible, production-ready CLI framework for MoonBit with built-in internationalization support.

## Features

- **Command Routing**: Easy command registration and execution
- **Flag Parsing**: Type-safe flag support (boolean, string, int, multiple)
- **Built-in Help**: Auto-generated help text for commands
- **i18n Support**: Built-in English and Chinese translations, extensible
- **Terminal UI**: Spinner animations and terminal utilities
- **Comprehensive Testing**: Full test coverage with 26+ tests

## Installation

Add `mug` to your project dependencies:

```bash
moon add colmugx/mug
```

## Quick Start

```moonbit
// main.mbt
fn main {
  let app = @app.App::new("mycli", "My CLI tool")
  app.version("1.0.0")

  // Add your commands
  let hello_cmd = HelloCommand::{}
  app.add_command(hello_cmd)

  // Execute with command-line arguments
  let args = @sys.argv.get_view()
  app.execute(args)
}

// hello_cmd.mbt
pub struct HelloCommand {}

impl TCommand for HelloCommand with name(_) {
  "hello"
}

impl TCommand for HelloCommand with description(_) {
  "Say hello"
}

impl TCommand for HelloCommand with execute(self, args) {
  println("Hello, World!")
}

impl HelpPrinter for HelloCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
```

## Usage

### Creating an App

```moonbit
// Basic app
let app = @app.App::new("mycli", "My CLI tool")

// Set version
app.version("1.0.0")

// Add custom command
app.add_command(my_command)

// Run
app.execute(@sys.argv.get_view())
```

### Internationalization (i18n)

Mug has built-in i18n support with English and Chinese translations:

```moonbit
// Auto-detects system locale
let app = @app.App::new("mycli", "My CLI tool")

// Set specific locale
let app_zh = app.with_locale("zh-CN")

// Add custom translations
let custom = { "greeting": "Hello, World!" }
let app_custom = app.with_translations("en-US", custom)

// Disable i18n (returns English or key)
let app_no_i18n = app.disable_i18n()

// Enable i18n
let app_with_i18n = app_no_i18n.enable_i18n()
```

#### Using i18n in Commands

```moonbit
pub struct MyCommand {
  app: @app.App
}

impl TCommand for MyCommand with description(self) {
  self.app.i18n.t("my.command.description")
}
```

### Creating Commands

#### Basic Command

```moonbit
pub struct MyCommand {}

impl TCommand for MyCommand with name(_) {
  "mycommand"
}

impl TCommand for MyCommand with description(_) {
  "Description of my command"
}

impl TCommand for MyCommand with execute(self, args) {
  // Command logic here
  println("Executing my command!")
}

impl HelpPrinter for MyCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
```

#### Command with App Reference

```moonbit
pub struct MyCommand {
  app: @app.App
}

impl TCommand for MyCommand with execute(self, args) {
  // Can access app properties
  let ver = self.app.version()
  println("App version: \{ver.unwrap_or(\"unknown\")}")
}
```

### Built-in Commands

Mug includes two built-in commands:

- **help**: Show help information
- **version**: Show version

These are automatically added when you call `app.execute()`.

## Advanced Features

### Flag Support

Create commands with flag support using `FlaggableCommand`:

```moonbit
use @flaggable::FlaggableCommand
use @flag::Flag

let cmd = FlaggableCommand::new("download", "Download files")
  |> FlaggableCommand::with_executor(fn(args) {
    // Download logic
  })
  |> FlaggableCommand::add_flag_def(Flag::new(
    name="output",
    description="Output directory",
    short="o",
    type?=FlagType::String
  ))

app.add_command(cmd)
```

### Terminal UI

Use the spinner for progress indication:

```moonbit
use @tui::Spinner

let spinner = Spinner::new("Downloading...")
for i in 0..10 {
  spinner.tick()
  @ffi.sleep(100)
}
spinner.finish("done")
```

## Testing

Mug has comprehensive test coverage. Run tests:

```bash
moon test
```

## API Documentation

- [@app.App](src/app.mbt) - Main application structure
- [@command.TCommand](src/command.mbt) - Command trait
- [@i18n.I18n](src/i18n/api.mbt) - Internationalization
- [@tui.Spinner](src/tui.mbt) - Terminal UI utilities
- [@flag.Flag](src/flag.mbt) - Flag definitions

## Examples

See the `examples/` directory for complete working examples:

- `examples/basic/` - Minimal CLI application
- `examples/with-i18n/` - Multilingual support
- `examples/with-flags/` - Flag parsing

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
