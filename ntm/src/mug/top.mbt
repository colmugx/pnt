///|
struct App {
  name : String
  description : String
  commands : Array[Command]
}

///|
pub fn App::new(name : String, description : String) -> App {
  { name, description, commands: [] }
}

///|
pub fn App::add_command(self : App, command : Command) -> Unit {
  self.commands.push(command)
}

///|
pub fn App::execute(self : App, args : ArrayView[String]) -> Unit {
  if args.length() == 0 {
    self.print_help()
    return
  }
  let cmd_name = args[0]
  let mut found_cmd = false
  for cmd in self.commands {
    if cmd.name == cmd_name {
      cmd.execute(args[1:])
      found_cmd = true
      break
    }
  }
  if not(found_cmd) {
    self.print_help()
  }
}

///|
fn App::print_help(self : App) -> Unit {
  let info =
    $| \{self.description}
    #|
    #| Usage:
    $| \{self.name} [OPTIONS] <COMMAND>
  println(info)
  if not(self.commands.is_empty()) {
    println("\nCommands:")
    for cmd in self.commands {
      cmd.print_usage()
    }
  }
}
