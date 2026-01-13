///|
/// Default implementation for commands with flags
pub struct FlaggableCommand {
  name : String
  description : String
  flags : Array[Flag]
  execute_fn : (ArrayView[String]) -> Unit
}

///|
pub fn FlaggableCommand::new(
  name : String,
  description : String,
) -> FlaggableCommand {
  {
    name,
    description,
    flags: [],
    execute_fn: fn(args) {
      ignore(args)
      ()
    },
  }
}

///|
pub fn FlaggableCommand::with_executor(
  self : FlaggableCommand,
  exec_fn : (ArrayView[String]) -> Unit,
) -> FlaggableCommand {
  {
    name: self.name,
    description: self.description,
    flags: self.flags,
    execute_fn: exec_fn,
  }
}

///|
pub fn FlaggableCommand::add_flag_def(
  self : FlaggableCommand,
  flag : Flag,
) -> FlaggableCommand {
  let new_flags = []
  for f in self.flags {
    new_flags.push(f)
  }
  new_flags.push(flag)
  {
    name: self.name,
    description: self.description,
    flags: new_flags,
    execute_fn: self.execute_fn,
  }
}

///|
impl TCommand for FlaggableCommand with execute(self, args) {
  (self.execute_fn)(args)
}

///|
impl TCommand for FlaggableCommand with execute_async(self, args) {
  self.execute(args)
}

///|
impl TCommand for FlaggableCommand with name(self) {
  self.name
}

///|
impl TCommand for FlaggableCommand with description(self) {
  self.description
}

///|
impl TCommand for FlaggableCommand with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
/// Parse flags from arguments
fn parse_command_flags(args : Array[String], flags : Array[Flag]) -> ParsedArgs {
  // Build flag map
  let flag_map : Map[String, Flag] = Map::new()
  for flag in flags {
    flag_map[flag.name] = flag
  }

  // Parse arguments
  match parse_args(args, flag_map) {
    Ok(parsed) => parsed
    Err(e) => {
      println("Error parsing flags: \{e}")
      { positional: [], flags: Map::new() }
    }
  }
}

///|
impl TFlaggable for FlaggableCommand with get_flag_string(self, args, flag_name) {
  let parsed = parse_command_flags(args, self.flags)
  match parsed.get_string(flag_name) {
    Ok(s) => Ok(s)
    Err(e) => Err(FlagError::NotFound(e))
  }
}

///|
impl TFlaggable for FlaggableCommand with get_flag_int(self, args, flag_name) {
  let parsed = parse_command_flags(args, self.flags)
  match parsed.get_int(flag_name) {
    Ok(i) => Ok(i)
    Err(e) => Err(FlagError::NotFound(e))
  }
}

///|
impl TFlaggable for FlaggableCommand with get_flag_multiple(
  self,
  args,
  flag_name,
) {
  let parsed = parse_command_flags(args, self.flags)
  parsed.get_multiple(flag_name)
}

///|
impl TFlaggable for FlaggableCommand with print_flag_help(self) {
  println("Flags:")
  for flag in self.flags {
    let short_str = match flag.short {
      Some(s) => " -\{s}"
      None => ""
    }
    println("  --\{flag.name}\{short_str}")
    println("    \{flag.description}")
  }
}
