///|
/// CLI application with i18n support using Mug framework
/// This example demonstrates internationalization features

pub fn main {
  // Create app with auto-detected locale
  let app = @app.App::new("i18n-demo", "CLI with i18n support")

  // Set version
  app.version("1.0.0")

  // Add custom translations
  let translations : Map[String, String] = {
    "greet.description": "Greet someone by name",
    "greet.hello": "Hello",
    "greet.welcome": "Welcome",
    "farewell.description": "Say goodbye",
    "farewell.goodbye": "Goodbye",
    "farewell.seeya": "See you again",
    "errors.no_name": "Error: Please provide a name"
  }

  let app_with_i18n = app.with_translations("en-US", translations)

  // Add commands that use i18n
  let greet = GreetCommand::{ app: app_with_i18n }
  app_with_i18n.add_command(greet)

  let farewell = FarewellCommand::{ app: app_with_i18n }
  app_with_i18n.add_command(farewell)

  // Execute
  let args = @sys.argv.get_view()
  app_with_i18n.execute(args)
}

///|
/// Greet command - demonstrates using i18n in commands
pub struct GreetCommand {
  app: @app.App
}

impl TCommand for GreetCommand with name(_) {
  "greet"
}

impl TCommand for GreetCommand with description(self) {
  self.app.i18n.t("greet.description")
}

impl TCommand for GreetCommand with execute(self, args) {
  if args.length() == 0 {
    println(self.app.i18n.t("errors.no_name"))
    println("Usage: i18n-demo greet <name>")
    return
  }

  let name = args[0]

  // Use i18n for user-facing messages
  let hello = self.app.i18n.t("greet.hello")
  let welcome = self.app.i18n.t("greet.welcome")

  println("\{hello}, \{name}!")
  println(welcome)
}

impl HelpPrinter for GreetCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
  println("    Usage: i18n-demo greet <name>")
}

///|
/// Farewell command - another example of i18n usage
pub struct FarewellCommand {
  app: @app.App
}

impl TCommand for FarewellCommand with name(_) {
  "farewell"
}

impl TCommand for FarewellCommand with description(self) {
  self.app.i18n.t("farewell.description")
}

impl TCommand for FarewellCommand with execute(self, args) {
  if args.length() == 0 {
    println(self.app.i18n.t("errors.no_name"))
    println("Usage: i18n-demo farewell <name>")
    return
  }

  let name = args[0]

  // Use i18n for messages
  let goodbye = self.app.i18n.t("farewell.goodbye")
  let seeya = self.app.i18n.t("farewell.seeya")

  println("\{goodbye}, \{name}!")
  println(seeya)
}

impl HelpPrinter for FarewellCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
  println("    Usage: i18n-demo farewell <name>")
}
