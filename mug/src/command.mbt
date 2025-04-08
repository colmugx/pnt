///|
type! ParseError String

///| 命令或子命令
struct Command {
  name : String
  description : String
  flags : Array[Flag]?
}

///|
pub fn Command::new(
  name : String,
  description : String
) -> Command {
  Command::{
    name,
    description,
    flags: None,
  }
}

///|
pub fn Command::parse(self : Command, args : Array[String]) -> Unit!ParseError {

  if args.is_empty() {
    self.print_usage()
    raise ParseError("Parse Error")
  }

  for arg in args {
    if arg == "-h" || arg == "--help" {
			self.print_usage()
			return
		}
  }
}

///|
fn Command::print_usage(self : Command) -> Unit {
  let args = @sys.get_cli_args()
  let app_name = args.get(0).unwrap()
  let explain =
    $|Usage: \{app_name} \{self.name}
    $| \{self.description}
  println(explain)
}
