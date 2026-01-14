///|
pub(open) trait TApplication {
  execute(Self, ArrayView[String]) -> Unit
  async execute_async(Self, ArrayView[String]) -> Unit
  add_command(Self, &TCommand) -> Self
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
  ver : String?
  default_commands_added : Bool
  i18n : @i18n.I18n
}

///|
pub fn App::new(name : String, description : String) -> App {
  let basic_translations : Map[String, String] = {
    "help": "Show help information",
    "version": "Show version",
    "command.not_found": "Command not found",
    "error.unknown_flag": "Unknown flag",
    "error.missing_value": "Missing value for flag",
    "app.usage": "Usage",
    "app.available_commands": "Available commands",
    "app.options": "Options",
  }
  let i18n = @i18n.I18n::with_translations("en-US", basic_translations)
  {
    name,
    description,
    commands: [],
    ver: None,
    default_commands_added: false,
    i18n,
  }
}

///|
pub fn App::with_locale(self : App, locale : String) -> App {
  let new_i18n = @i18n.I18n::with_locale(locale).unwrap_or(self.i18n)
  { ..self, i18n: new_i18n }
}

///|
pub fn App::with_translations(
  self : App,
  locale : String,
  translations : Map[String, String],
) -> App {
  let new_i18n = @i18n.I18n::with_translations(locale, translations)
  { ..self, i18n: new_i18n }
}

///|
pub fn App::disable_i18n(self : App) -> App {
  { ..self, i18n: self.i18n.disable() }
}

///|
pub fn App::enable_i18n(self : App) -> App {
  { ..self, i18n: self.i18n.enable() }
}

///|
pub fn App::ensure_default_commands(self : App) -> App {
  if self.default_commands_added {
    return self
  }
  let help = HelpCommand::{ app: self }
  let version = VersionCommand::{ app: self }
  let new_commands : Array[&TCommand] = []
  for cmd in self.commands {
    new_commands.push(cmd)
  }
  new_commands.push(help)
  new_commands.push(version)
  { ..self, commands: new_commands, default_commands_added: true }
}

///|
pub fn App::version(self : App, version : String) -> App {
  { ..self, ver: Some(version) }
}

///|
pub impl TApplication for App with execute(self, args : ArrayView[String]) {
  let app = self.ensure_default_commands()
  if args.length() == 0 {
    app.print_help()
    return
  }
  let cmd_name = args[0]
  guard app.find_command(cmd_name) is Some(cmd) else {
    app.print_help()
    return
  }
  let cmd_args = args[1:]
  if cmd_args.length() != 0 && (cmd_args[0] == "--help" || cmd_args[0] == "-h") {
    cmd.print_usage()
    return
  }
  cmd.execute(cmd_args)
}

///|
pub impl TApplication for App with execute_async(self, args : ArrayView[String]) {
  let app = self.ensure_default_commands()
  if args.length() == 0 {
    app.print_help()
    return
  }
  let cmd_name = args[0]
  guard app.find_command(cmd_name) is Some(cmd) else {
    app.print_help()
    return
  }
  let cmd_args = args[1:]
  if cmd_args.length() != 0 && (cmd_args[0] == "--help" || cmd_args[0] == "-h") {
    cmd.print_usage()
    return
  }
  cmd.execute_async(cmd_args)
}

///|
pub impl TApplication for App with add_command(self, command : &TCommand) -> App {
  let new_commands : Array[&TCommand] = []
  for cmd in self.commands {
    new_commands.push(cmd)
  }
  new_commands.push(command)
  { ..self, commands: new_commands }
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
