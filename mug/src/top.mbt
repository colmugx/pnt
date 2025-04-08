///|
struct App {
  description : String
  commands : Array[Command]
}

///|
pub fn App::new(description : String) -> App {
  { description, commands: [] }
}

pub fn App::add_command(self: App, command: Command) -> Unit {
  self.commands.push(command)
}