///|
suberror FetchListError {
  FetchListError(String)
} derive(Show)

///|
pub struct RemoteNode {
  version : String
  date : String
  files : Array[String]
  lts : Json
  security : Bool
} derive(@json.FromJson, ToJson)

///|
pub async fn fetch_list() -> Array[RemoteNode] raise FetchListError {
  let list_url = "https://nodejs.org/dist/index.json"
  let (_, body) = @http.get(list_url) catch {
    _ => raise FetchListError("http request failed")
  }
  let json = body.json() catch { _ => raise FetchListError("read body failed") }
  let data = @json.from_json(json) catch {
    _ => raise FetchListError("convert json failed.")
  }
  data
}

///|
pub fn list_node() -> Array[String] {
  @fs.read_dir(get_version_dir()) catch {
    _ => []
  }
}

///|
pub fn get_current_version() -> String? {
  let path = "\{get_bin_dir()}/node"
  let ori_path = @ffi.read_link(path) catch { _ => return None }
  ori_path
  .split("/")
  .find_first(fn(item) {
    item.has_prefix("v") &&
    item.length() > 1 &&
    item[1] >= '0' &&
    item[1] <= '9'
  })
  .map(fn(s) { s.to_string() })
}

///|
pub fn is_version_installed(ver : String) -> Bool {
  @fs.path_exists("\{get_version_dir()}/\{ver}")
}

///|
pub fn remove_by_version(ver : String) -> Unit raise {
  let path = "\{get_version_dir()}/\{ver}"
  remove_all(path)
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
  version~ : String,
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
