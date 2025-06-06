///|
type! FetchListError String derive(Show)

///|
pub struct RemoteNode {
  version : String
  date : String
  files : Array[String]
  lts : @json.JsonValue
  security : Bool
} derive(@json.FromJson)

///|
pub fn fetch_list() -> Array[RemoteNode]!FetchListError {
  let list_url = "https://nodejs.org/dist/index.json"
  let resp = try @ffi.get!(list_url) catch {
    @ffi.NetworkError(err) => raise FetchListError(err)
    _ => ""
  }
  guard @json.parse?(resp) is Ok(json) else {
    raise FetchListError("parse json failed.")
  }
  guard @json.from_json?(json) is Ok(data) else {
    raise FetchListError("convert json failed.")
  }
  let data : Array[RemoteNode] = data
  data
}

///|
pub fn list_node() -> Array[String] {
  @fs.read_dir?(get_version_dir()).or([])
}

///|
pub fn get_current_version() -> @string.StringView? {
  let path = "\{get_bin_dir()}/node"
  let ori_path = @ffi.read_link(path)
  ori_path
  .split("/")
  .find_first(fn { item => item is ['v', c, ..] && c.is_ascii_digit() })
}

///|
pub fn is_version_installed(ver : String) -> Bool {
  @fs.path_exists("\{get_version_dir()}/\{ver}")
}

///|
pub fn remove_by_version(ver : String) -> Unit! {
  let path = "\{get_version_dir()}/\{ver}"
  @ffi.remove_dir!(path)
}

///|
pub fn normalize_version(ver : String) -> String {
  if ver.is_empty() {
    return ""
  }
  if ver.has_prefix("v") {
    ver
  } else {
    "v\{ver}"
  }
}

///|
pub fn format_node_tarball(
  os_tag~ : String,
  cpu_arch~ : String,
  version~ : String
) -> String {
  "node-\{version}-\{os_tag}-\{cpu_arch}.tar.gz"
}

///|
pub fn get_version_dir() -> String {
  let app_dir = get_app_dir()
  "\{app_dir}/versions"
}

///|
pub fn get_bin_dir() -> String {
  let app_dir = get_app_dir()
  "\{app_dir}/bin"
}
