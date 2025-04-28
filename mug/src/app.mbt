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
pub trait CommandManager {
  find_command(Self, String) -> &TCommand?
}

///| 
pub struct App {
  name : String
  description : String
  commands : Array[&TCommand]
  ver : String?
}

///|
pub fn App::new(
  name : String,
  description : String,
  version~ : String? = None
) -> App {
  { name, description, commands: [], ver: version }
}

///|
pub impl TApplication for App with execute(self, args : ArrayView[String]) {
  if args.length() == 0 {
    self.print_help()
    return
  }
  let cmd_name = args[0]
  match cmd_name {
    "--help" | "-h" => self.print_help()
    "--version" | "-v" => self.print_version()
    _ => {
      guard self.find_command(cmd_name) is Some(cmd) else {
        self.print_help()
        return
      }
      let args = args[1:]
      if args.length() != 0 && (args[0] == "--help" || args[0] == "-h") {
        cmd.print_usage()
        return
      }
      cmd.execute(args)
    }
  }
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
  println(self.ver.or("0.0.0"))
}

///|
impl CommandManager for App with find_command(self, name : String) {
  self.commands.iter().find_first(fn { cmd => cmd.name() == name })
}

///|
// pub fn App::register(
//   self : App,
//   cmds : Array[(String, String, TAction)]
// ) -> Unit {
//   let cmds = cmds.map(fn {
//     (name, desc, action) => Command::new(name, desc, action)
//   })
//   self.commands.append(cmds)
// }
