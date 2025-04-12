///|
struct App {
  name : String
  cmd : String
  description : String
  commands : Array[Command]
  version : String?
}

///|
pub fn App::new(
  name : String,
  description : String,
  cmd~ : String = "",
  version~ : String?
) -> App {
  let cmd = if cmd.is_empty() { name } else { cmd }
  { name, cmd, description, commands: [], version }
}

///|
pub fn App::add_command(self : App, command : Command) -> Unit {
  self.commands.push(command)
}

///|
pub fn App::register(self : App, cmds : Array[TCmd]) -> Unit {
  let cmds = cmds.map(fn { cmd => Command::new(cmd) })
  self.commands.append(cmds)
}

///|
pub fn App::execute(self : App, args : ArrayView[String]) -> Unit {
  if args.length() == 0 {
    self.print_help()
    return
  }
  let cmd_name = args[0]
  match cmd_name {
    "--help" | "-h" => self.print_help()
    _ => {
      guard self.find_command(cmd_name) is Some(cmd) else { self.print_help() }
      self.handle_command_help(cmd, args[1:])
    }
  }
}

///|
fn App::handle_command_help(
  _ : App,
  command : Command,
  args : ArrayView[String]
) -> Unit {
  if args.length() != 0 && (args[0] == "--help" || args[0] == "-h") {
    command.print_usage()
  } else {
    command.execute(args)
  }
}

///|
fn App::find_command(self : App, name : String) -> Command? {
  self.commands.iter().find_first(fn { cmd => cmd.name == name })
}

///|
fn App::print_help(self : App) -> Unit {
  let info =
    $|\{self.description}
    #|
    #|Usage:
    $|  \{self.cmd} [OPTIONS] <COMMAND>
  println(info)
  if not(self.commands.is_empty()) {
    println("\nCommands:")
    for cmd in self.commands {
      cmd.print_usage()
    }
  }
}
