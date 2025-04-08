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
  ("list", "列出已安装的 Node.js 版本。", action),
)

///|
fn init {
  let lts_flag = @mug.Flag::new("lts", "List only LTS versions")
  list_remote_cmd.add_flag(lts_flag)
}

///|
fn action(args : @mug.TArgs) -> Unit {
  let list_url = "https://nodejs.org/dist/index.json"
  let resp = @request.get(list_url)
  guard @json.parse?(resp) is Ok(json) else { return }
  guard @json.from_json?(json) is Ok(data) else { return }
  let data : Array[RemoteNode] = data
  data
  .iter()
  .fold(init=[], fn { list, item => [item, ..list] })
  .each(fn { item => println(item.version) })
}
