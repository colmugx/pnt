///|
priv type! FetchError

///|
struct RemoteNode {
  version : String
  date : String
  files : Array[String]
  lts : @json.JsonValue
  security : Bool
} derive(@json.FromJson)

///|
pub let list_remote_cmd : @mug.Command = @mug.Command::new(
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
  let mut list = fetch_list?().or([])
  if is_lts {
    list = list.filter(fn { item => not(item.lts.as_string().or("").is_blank()) })
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

///|
fn fetch_list() -> Array[RemoteNode]!FetchError {
  let list_url = "https://nodejs.org/dist/index.json"
  let resp = @request.get(list_url)
  guard @json.parse?(resp) is Ok(json) else { raise FetchError }
  guard @json.from_json?(json) is Ok(data) else { raise FetchError }
  let data : Array[RemoteNode] = data
  data.rev()
}
