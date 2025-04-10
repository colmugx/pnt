///|
type! ParseError String

///|
pub typealias TArgs = ArrayView[String]

///|
typealias TAction = (Command, TArgs) -> Unit

///|
typealias TCmd = (String, String, TAction)

///| 命令或子命令
struct Command {
  name : String
  description : String
  flags : Map[String, Flag]
  s_flags : Map[String, String]
  action : TAction
}

///|
pub fn Command::new(options : TCmd) -> Command {
  let (name, description, action) = options
  Command::{ name, description, flags: {}, s_flags: {}, action }
}

///|
pub fn Command::add_flag(self : Command, flag : Flag) -> Unit {
  self.flags.set(flag.name, flag)
  match flag.short {
    Some(s) => self.s_flags.set(s, flag.name)
    _ => ignore(())
  }
}

///|
pub fn Command::is_flag_exist(
  self : Command,
  args : TArgs,
  key : String
) -> Bool {
  let parsed_flags = self.parse_flags(args)
  for name in parsed_flags.keys() {
    if self.flags.contains(name) && name == key {
      return true
    }
  }
  false
}

///|
fn parse_flags(self : Command, args : TArgs) -> Map[String, String] {
  let parsed : Map[String, String] = {}
  let mut i = 0
  while i < args.length() {
    let arg = args[i]
    if arg.starts_with("--") {
      let start = arg.offset_of_nth_char(2).unwrap()
      let end = arg.offset_of_nth_char(arg.length() - 1).unwrap()
      let long = arg.view(start_offset=start, end_offset=end + 1).to_string()
      if self.flags.contains(long) {
        parsed.set(long, "--\{long}")
      } else {
        // Unknown flag
      }
    } else if arg.starts_with("-") && arg.length() > 1 {
      let short = arg[1].to_string()
      guard self.s_flags.get(short) is Some(long) else {
        // Unknown flag

      }
      parsed.set(long, "-\{long}")
    }
    i += 1
  }
  parsed
}

///|
fn Command::print_usage(self : Command) -> Unit {
  println("  \{self.name} - \{self.description}")
}

///|
fn Command::execute(self : Command, args : TArgs) -> Unit {

  // TODO: 后续操作
  (self.action)(self, args)
}
