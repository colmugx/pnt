///|
type! FetchError

///|
pub struct RemoteNode {
  version : String
  date : String
  files : Array[String]
  lts : @json.JsonValue
  security : Bool
} derive(@json.FromJson)

///|
pub fn fetch_list() -> Array[RemoteNode]!FetchError {
  let list_url = "https://nodejs.org/dist/index.json"
  let resp = @request.get(list_url)
  guard @json.parse?(resp) is Ok(json) else { raise FetchError }
  guard @json.from_json?(json) is Ok(data) else { raise FetchError }
  let data : Array[RemoteNode] = data
  data
}

///|
pub fn get_current_version() -> Unit {

}

///|
pub fn normalize_version(ver : String) -> String {
  if ver.starts_with("v") {
    ver
  } else {
    "v\{ver}"
  }
}
