///|
priv struct UseCmd {
  name : String
  description : String
}

///|
fn replace_node_symlinks(version : String) -> Unit {
  let tools = ["node", "npm", "npx"]
  for tool in tools {
    @util.replace_symlink(tool, version)
  }
}

///|
/// 获取版本号
async fn use_get_version(tag : String) -> String {
  guard tag is "lts" || tag is "latest" else { @util.normalize_version(tag) }
  let list = @util.fetch_list() catch { _ => {
    println("Error: Failed to fetch available versions")
    return ""
  }}
  match tag {
    "lts" => {
      let latest_lts = list
        .iter()
        .find_first(fn(item) {
          if item.lts is String(s) {
            s.is_empty()
          } else {
            false
          }
        })
        .unwrap()
      let version = @util.normalize_version(latest_lts.version)
      println("Latest LTS version is \{version}")
      version
    }
    "latest" => {
      let version = @util.normalize_version(list[0].version)
      println("Latest version is \{version}")
      version
    }
    _ => ""
  }
}

///|
impl @mug.TCommand for UseCmd with execute(_, args) {
  // Synchronous version - cannot call async functions
  ignore(args)
  println("Error: use command requires async context")
}

///|
impl @mug.TCommand for UseCmd with execute_async(_, args) {
  let version = use_get_version(args[0])
  if version.is_empty() {
    println("Error fetching available versions.")
    return
  }
  if not(@util.is_version_installed(version)) {
    println(
      "Node.js \{version} is not installed. Install it first with 'pnt install \{version}'",
    )
    return
  }
  let node_bin = "\{@util.get_version_dir()}/\{version}/bin/node"

  // 检查二进制执行
  if not(@util.path_is_exist(node_bin)) {
    println("Node binary not found in \{node_bin}")
    return
  }
  replace_node_symlinks(version)
  println(
    (
      $|Now using Node.js \{version}
      #|Add this to your shell profile to use pnt:
      $|  export PATH="\{@util.get_bin_dir()}:$PATH"
    ),
  )
}

///|
impl @mug.TCommand for UseCmd with name(self) {
  self.name
}

///|
impl @mug.TCommand for UseCmd with description(self) {
  self.description
}

///|
impl @mug.TCommand for UseCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let use_cmd : UseCmd = {
  name: "use",
  description: "Switch to a specific version of Node.js. If version is \"lts\", the latest installed LTS version will be used.",
}
