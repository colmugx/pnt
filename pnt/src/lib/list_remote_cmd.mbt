///|
priv struct ListRemoteCmd {
  name : String
  description : String
  flags : Map[String, @mug.Flag]
  s_flags : Map[String, String]
}

///|
fn format_version(item : @util.RemoteNode) -> String {
  let lts = if item.lts is String(s) { "(\{s})" } else { "" }
  "\{item.version} \{lts}"
}

///|
fn ListRemoteCmd::parse_flags(
  self : ListRemoteCmd,
  args : ArrayView[String],
) -> Map[String, String] {
  let parsed : Map[String, String] = {}
  let mut i = 0
  while i < args.length() {
    let arg = args[i]
    if arg.has_prefix("--") {
      let start = 2
      let end = arg.length()
      let long = arg.substring(start~, end~)
      if self.flags.contains(long) {
        parsed.set(long, "--\{long}")
      }
    } else if arg.has_prefix("-") && arg.length() > 1 {
      let short = arg.substring(start=1, end=2)
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
fn ListRemoteCmd::add_flag(self : ListRemoteCmd, flag : @mug.Flag) -> Unit {
  self.flags.set(flag.name, flag)
  if flag.short is Some(s) {
    self.s_flags.set(s, flag.name)
  }
}

///|
fn ListRemoteCmd::has_flag(
  self : ListRemoteCmd,
  args : ArrayView[String],
  key : String,
) -> Bool {
  let parsed_flags = self.parse_flags(args)
  parsed_flags.contains(key)
}

///|
fn ListRemoteCmd::print_flag_help(self : ListRemoteCmd) -> Unit {
  println("Flags:")
  let keys = self.flags.keys().to_array()
  let mut i = 0
  while i < keys.length() {
    let name = keys[i]
    match self.flags.get(name) {
      Some(flag) => {
        let short_str = match flag.short {
          Some(s) => " -\{s}"
          None => ""
        }
        println("  --\{name}\{short_str}")
        println("    \{flag.description}")
      }
      None => ()
    }
    i = i + 1
  }
}

///|
impl @mug.TCommand for ListRemoteCmd with execute(_, args) {
  ignore(args)
}

///|
impl @mug.TCommand for ListRemoteCmd with execute_async(self, args) {
  // Async version - can call fetch_list
  let list = @util.fetch_list() catch { _ => [] }
  let filtered = if self.has_flag(args, "lts") {
    list.filter(fn(item) {
      if item.lts is String(s) {
        not(s.is_empty())
      } else {
        false
      }
    })
  } else {
    list
  }
  filtered.each(fn(item) { println(format_version(item)) })
}

///|
impl @mug.TCommand for ListRemoteCmd with name(self) {
  self.name
}

///|
impl @mug.TCommand for ListRemoteCmd with description(self) {
  self.description
}

///|
impl @mug.TCommand for ListRemoteCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
  self.print_flag_help()
}

///|
let list_remote_cmd : ListRemoteCmd = {
  name: "list-remote",
  description: "List all available Node.js versions that can be installed.",
  flags: {},
  s_flags: {},
}

///|
fn init {
  let lts_flag = @mug.Flag::new("lts", "List only LTS versions")
  list_remote_cmd.add_flag(lts_flag)
}
