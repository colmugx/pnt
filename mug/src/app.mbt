///|
pub(open) trait TApplication {
  execute(Self, ArrayView[String]) -> Unit
  add_command(Self, &TCommand) -> Unit
  version(Self) -> String?
}

///| 
pub trait AppHelpPrinter {
  print_help(Self) -> Unit
  print_version(Self) -> Unit
}

///|
pub(open) trait CommandManager {
  find_command(Self, String) -> &TCommand?
}

///|
pub struct App {
  name : String
  description : String
  commands : Array[&TCommand]
  mut ver : String?
  mut default_commands_added : Bool
  mut i18n : @i18n.I18n
}

///|
pub fn App::new(name : String, description : String) -> App {
  // Initialize i18n with basic English translations
  let basic_translations : Map[String, String] = {
    "help": "Show help information",
    "version": "Show version",
    "command.not_found": "Command not found",
    "error.unknown_flag": "Unknown flag",
    "error.missing_value": "Missing value for flag",
    "app.usage": "Usage",
    "app.available_commands": "Available commands",
    "app.options": "Options"
  }
  let i18n = @i18n.I18n::with_translations("en-US", basic_translations)
  { name, description, commands: [], ver: None, default_commands_added: false, i18n }
}

///|
pub fn App::with_locale(self : App, locale : String) -> App {
  self.i18n = @i18n.I18n::with_locale(locale).unwrap_or(self.i18n)
  self
}

///|
pub fn App::with_translations(
  self : App,
  locale : String,
  translations : Map[String, String]
) -> App {
  self.i18n = @i18n.I18n::with_translations(locale, translations)
  self
}

///|
pub fn App::disable_i18n(self : App) -> App {
  self.i18n = self.i18n.disable()
  self
}

///|
pub fn App::enable_i18n(self : App) -> App {
  self.i18n = self.i18n.enable()
  self
}

///|
pub fn App::ensure_default_commands(self : App) -> Unit {
  if self.default_commands_added { return }
  self.default_commands_added = true
  let help = HelpCommand::{ app: self }
  let version = VersionCommand::{ app: self }
  self.add_command(help)
  self.add_command(version)
}

///|
pub fn App::version(self : App, version : String) -> Unit {
  self.ver = Some(version)
}

///|
pub impl TApplication for App with execute(self, args : ArrayView[String]) {
  self.ensure_default_commands()
  if args.length() == 0 {
    self.print_help()
    return
  }
  let cmd_name = args[0]
  guard self.find_command(cmd_name) is Some(cmd) else {
    self.print_help()
    return
  }
  let args = args[1:]
  if args.length() != 0 && (args[0] == "--help" || args[0] == "-h") {
    cmd.print_usage()
    return
  }
  // Convert ArrayView to Array for TCommand.execute
  let args_array = Array::from_iter(args.iter())
  cmd.execute(args_array)
}

///|
pub impl TApplication for App with add_command(self, command : &TCommand) -> Unit {
  self.commands.push(command)
}

///|
pub impl TApplication for App with version(self) -> String? {
  self.ver
}

///|
impl AppHelpPrinter for App with print_help(self) {
  let info =
    $|\{self.description}
    #|
    #|Usage:
    $|  \{self.name} [OPTIONS] <COMMAND>
  println(info)
  if not(self.commands.is_empty()) {
    println("\nCommands:")
    for cmd in self.commands {
      cmd.print_usage()
    }
  }
}

///|
impl AppHelpPrinter for App with print_version(self) {
  println(self.ver.unwrap_or("0.0.0"))
}

///|
impl CommandManager for App with find_command(self, name : String) {
  self.commands.iter().find_first(fn(cmd) { cmd.name() == name })
}
