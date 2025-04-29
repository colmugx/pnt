///|
priv struct ListRemoteCmd {
  name : String
  description : String
  flags : Map[String, @mug.Flag]
  s_flags : Map[String, String]
}

///|
fn format_version(item : @util.RemoteNode) -> String {
  let lts = item.lts.as_string().map_or("", fn { s => "(\{s})" })
  "\{item.version} \{lts}"
}

///|
fn ListRemoteCmd::parse_flags(
  self : ListRemoteCmd,
  args : @mug.TArgs
) -> Map[String, String] {
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
impl @mug.TFlaggable for ListRemoteCmd with add_flag(self, flag) {
  self.flags.set(flag.name, flag)
  if flag.short is Some(s) {
    self.s_flags.set(s, flag.name)
  }
}

///|
impl @mug.TFlaggable for ListRemoteCmd with has_flag(self, args, key) {
  let parsed_flags = self.parse_flags(args)
  for name in parsed_flags.keys() {
    if self.flags.contains(name) && name == key {
      return true
    }
  }
  false
}

///|
impl @mug.TCommand for ListRemoteCmd with execute(self, args) {
  let list = @util.fetch_list?().or([]).rev()
  let filtered = if self.has_flag(args, "lts") {
    list.filter(fn {
      item => item.lts.as_string().map_or(false, fn { s => not(s.is_empty()) })
    })
  } else {
    list
  }
  filtered.each(fn { item => println(format_version(item)) })
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
impl @mug.HelpPrinter for ListRemoteCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
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
