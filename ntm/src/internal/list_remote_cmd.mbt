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
fn list_remote_action(c : @mug.Command, args : @mug.TArgs) -> Unit {
  let is_lts = c.is_flag_exist(args, "lts")
  let mut list = @util.fetch_list?().or([]).rev()
  if is_lts {
    list = list.filter(fn {
      item => not(item.lts.as_string().or("").is_blank())
    })
  }
  list.each(fn {
    item => {
      let lts = match item.lts {
        String(s) => "(\{s})"
        _ => ""
      }
      println("\{item.version} \{lts}")
    }
  })
}
