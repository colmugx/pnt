///|
pub(open) trait TCommand {
  execute(Self, ArrayView[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
}

///|
pub(open) trait TFlaggable {
  has_flag(Self, TArgs, String) -> Bool
  add_flag(Self, Flag) -> Unit
}

///|
pub struct Command {
  name : String
  description : String
  flags : Map[String, Flag]
  s_flags : Map[String, String]
  action : TAction
}

///|
pub fn Command::new(
  name : String,
  description : String,
  action : TAction
) -> Command {
  { name, description, flags: {}, s_flags: {}, action }
}

///|
impl TCommand for Command with execute(self, args : ArrayView[String]) {
  (self.action)(self, args)
}

///|
impl TCommand for Command with name(self) {
  self.name
}

///|
impl TCommand for Command with description(self) {
  self.description
}

///|
pub impl TFlaggable for Command with has_flag(self, args : TArgs, key : String) {
  let parsed_flags = self.parse_flags(args)
  for name in parsed_flags.keys() {
    if self.flags.contains(name) && name == key {
      return true
    }
  }
  false
}

///|
pub impl TFlaggable for Command with add_flag(self, flag : Flag) {
  self.flags.set(flag.name, flag)
  if flag.short is Some(s) {
    self.s_flags.set(s, flag.name)
  }
}

///|
pub trait FlagParser {
  parse_flags(Self, TArgs) -> Map[String, String]
}

///|
impl FlagParser for Command with parse_flags(self, args : TArgs) {
  let parsed : Map[String, String] = {}
  let mut i = 0
  while i < args.length() {
    let arg = args[i]
    if arg.has_prefix("--") {
      let start = arg.offset_of_nth_char(2).unwrap()
      let end = arg.offset_of_nth_char(arg.length() - 1).unwrap()
      let long = arg.view(start_offset=start, end_offset=end + 1).to_string()
      if self.flags.contains(long) {
        parsed.set(long, "--\{long}")
      }
    } else if arg.has_prefix("-") && arg.length() > 1 {
      let short = arg[1].to_string()
      guard self.s_flags.get(short) is Some(long) else {
        i += 1
        continue
      }
      parsed.set(long, "-\{long}")
    }
    i += 1
  }
  parsed
}

///|
pub trait HelpPrinter {
  print_usage(Self) -> Unit
}

///|
impl HelpPrinter for Command with print_usage(self) {
  println("  \{self.name} - \{self.description}")
  if not(self.flags.is_empty()) {
    println("\nFlags:")
    for flag in self.flags.values() {
      Flag::print_usage(flag)
    }
  }
}

///|
pub typealias TArgs = ArrayView[String]

///|
typealias TAction = (Command, TArgs) -> Unit
