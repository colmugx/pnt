# Command Guide

This guide explains how to create and manage commands in Mug.

## Basic Command Structure

Every command must implement the `TCommand` trait:

```mbt
pub(open) trait TCommand: HelpPrinter {
  execute(Self, Array[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
}
```

## Creating a Simple Command

```mbt
pub struct GreetCommand {}

impl TCommand for GreetCommand with name(_) {
  "greet"
}

impl TCommand for GreetCommand with description(_) {
  "Greet someone"
}

impl TCommand for GreetCommand with execute(self, args) {
  if args.length() > 0 {
    println("Hello, \{args[0]}!")
  } else {
    println("Hello, World!")
  }
}

impl HelpPrinter for GreetCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
```

## Command with App Reference

To access app properties (like i18n), store an app reference:

```mbt
pub struct MyCommand {
  app: @app.App
}

impl TCommand for MyCommand with description(self) {
  // Use app's i18n
  self.app.i18n.t("my.command.description")
}

impl TCommand for MyCommand with execute(self, args) {
  // Can access app properties
  let ver = self.app.version()
  println("Running on version: \{ver.unwrap_or(\"unknown\")}")
}
```

## Command Arguments

The `execute` method receives an `Array[String]` of arguments:

```mbt
impl TCommand for MyCommand with execute(self, args) {
  // args is Array[String]
  for arg in args {
    println("Argument: \{arg}")
  }
}
```

### Parsing Arguments

For complex argument parsing, use the `@arg_parser` module:

```mbt
use @arg_parser::{parse_args, ParsedArgs}
use @flag::Flag

// Define your flags
let flags = [
  Flag::new("verbose", "Enable verbose output", short="v"),
  Flag::new("count", "Number of times", short="c", type?=FlagType::Int)
]

// Parse arguments
match parse_args(args, flags) {
  Ok(parsed) => {
    if parsed.has_flag("verbose") {
      println("Verbose mode")
    }
    match parsed.get_int("count") {
      Ok(n) => println("Count: \{n}")
      Err(_) => println("No count specified")
    }
  }
  Err(e) => {
    println("Error: \{e}")
  }
}
```

## Built-in Commands

Mug includes two built-in commands that are automatically added:

### Help Command

Shows help information for all commands:

```bash
mycli --help
mycli help
```

### Version Command

Displays the application version:

```bash
mycli --version
mycli version
```

## Command Best Practices

### 1. Use Descriptive Names

```mbt
// Good
impl TCommand for Command with name(_) {
  "download"
}

// Bad
impl TCommand for Command with name(_) {
  "dwnld"
}
```

### 2. Provide Clear Descriptions

```mbt
// Good
impl TCommand for Command with description(_) {
  "Download files from remote server"
}

// Bad
impl TCommand for Command with description(_) {
  "Downloads stuff"
}
```

### 3. Handle Errors Gracefully

```mbt
impl TCommand for MyCommand with execute(self, args) {
  if args.length() == 0 {
    println("Error: Missing required argument")
    println("Usage: mycli <name>")
    return
  }

  // Normal execution
  process(args[0])
}
```

### 4. Use i18n for User-Facing Strings

```mbt
impl TCommand for MyCommand with description(self) {
  self.app.i18n.t("commands.my.description")
}
```

## Complete Example

Here's a complete command example:

```mbt
///|
/// Command to download files
pub struct DownloadCommand {
  app: @app.App
}

impl TCommand for DownloadCommand with name(_) {
  "download"
}

impl TCommand for DownloadCommand with description(self) {
  self.app.i18n.t("commands.download.description")
}

impl TCommand for DownloadCommand with execute(self, args) {
  if args.length() == 0 {
    println(self.app.i18n.t("errors.missing_url"))
    return
  }

  let url = args[0]
  println("Downloading from: \{url}")

  // Download logic here
  download_file(url)
}

impl HelpPrinter for DownloadCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
  println("    Usage: \{self.name()} <url>")
}
```

## Testing Commands

Test your commands like this:

```mbt
test "MyCommand executes correctly" {
  let app = @app.App::new("test", "Test app")
  let cmd = MyCommand::{}

  // Execute with test arguments
  cmd.execute(["arg1", "arg2"])

  // Verify behavior
  inspect(result, content="expected")
}
```

See the [app_test.mbt](../src/app_test.mbt) for more examples.
