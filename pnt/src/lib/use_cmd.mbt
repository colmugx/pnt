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
impl @mug.TCommand for UseCmd with execute(_, args) {
  let version = get_version?(args[0]).or(String::default())
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

  // TODO
  let node_bin = "\{@util.get_version_dir()}/\{version}/bin/node"

  // 检查二进制执行
  if not(@util.path_is_exist(node_bin)) {
    println("Node binary not found in \{node_bin}")
    return
  }
  replace_node_symlinks(version)
  println(
    $|Now using Node.js \{version}
    #|Add this to your shell profile to use pnt:
    $|  export PATH="\{@util.get_bin_dir()}:$PATH"
    ,
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
impl @mug.HelpPrinter for UseCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let use_cmd : UseCmd = {
  name: "use",
  description: "Switch to a specific version of Node.js. If version is \"lts\", the latest installed LTS version will be used.",
}
