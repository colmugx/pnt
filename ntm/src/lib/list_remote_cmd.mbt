///|
let list_remote_cmd : @mug.Command = @mug.Command::new(
  (
    "list-remote", "List all available Node.js versions that can be installed.",
    list_remote_action,
  ),
)

///|
fn init {
  let lts_flag = @mug.Flag::new("lts", "List only LTS versions")
  list_remote_cmd.add_flag(lts_flag)
}

///|
fn format_version(item : @util.RemoteNode) -> String {
  let lts = item.lts.as_string().map_or("", fn { s => "(\{s})" })
  "\{item.version} \{lts}"
}

///|
fn list_remote_action(cmd : @mug.Command, args : @mug.TArgs) -> Unit {
  let list = @util.fetch_list?().or([]).rev()
  let filtered = if cmd.is_flag_exist(args, "lts") {
    list.filter(fn {
      item => item.lts.as_string().map_or(false, fn { s => not(s.is_empty()) })
    })
  } else {
    list
  }
  filtered.each(fn { item => println(format_version(item)) })
}
