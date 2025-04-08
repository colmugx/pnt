///|
type! ParseError String

///|
typealias TCmd = (String, String)

///| 命令或子命令
struct Command {
  name : String
  description : String
  flags : Array[Flag]
}

///|
pub fn Command::new(options : TCmd) -> Command {
  let (name, description) = options
  Command::{ name, description, flags: [] }
}

///|
pub fn Command::add_flag(self : Command, flag : Flag) -> Unit {
  self.flags.push(flag)
}

///|
fn Command::print_usage(self : Command) -> Unit {
  println("  \{self.name} - \{self.description}")
}

///|
fn Command::execute(self : Command, args : ArrayView[String]) -> Unit {
  println("Executing command: \{self.name}")
  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    let mut found_flag = false
    for flag in self.flags {
      if arg == flag.name {
        println("  Found flag: --\{flag.name} (\{flag.description})")
        found_flag = true
        break
      } else if flag.short is Some(short) && arg == short {
        println("  Found flag: -\{short} (\{flag.description})")
        found_flag = true
        break
      }
    }
    if not(found_flag) {
      println("  Warning: Unknown argument '\{arg}'")
    }
    i += 1
  }
}
