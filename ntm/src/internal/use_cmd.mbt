///|
let use_cmd : @mug.Command = @mug.Command::new(
  (
    "use", "Switch to a specific version of Node.js. If version is \"lts\", the latest installed LTS version will be used.",
    use_action,
  ),
)

///|
fn use_action(c : @mug.Command, args : @mug.TArgs) -> Unit {
  let list = @util.fetch_list?().or([])
  let version = match args[0] {
    "lts" => {
      let latest_lts = list
        .iter()
        .find_first(fn {
          item =>
            match item.lts.as_string() {
              None => false
              Some(_) => true
            }
        })
        .unwrap()
      let version = @util.normalize_version(latest_lts.version)
      println("Latest LTS version is \{version}")
      version
    }
    "latest" => {
      let latest_lts = list[0]
      let version = @util.normalize_version(latest_lts.version)
      println("Latest version is \{version}")
      version
    }
    str => @util.normalize_version(str)
  }
  if version.is_empty() {
    println("Error fetching available versions.")
    return
  }
  if not(@util.is_version_installed(version)) {
    println(
      "Node.js \{version} is not installed. Install it first with 'ntm install \{version}'",
    )
    return
  }
  let node_bin = "\{@util.get_version_dir()}/\{version}/bin/node"

  // 检查二进制执行
  if not(@util.path_is_exist(node_bin)) {
    println("Node binary not found in \{node_bin}")
    return
  }

  // 替换软链
  @util.replace_symlink("node", version)
  @util.replace_symlink("npm", version)
  @util.replace_symlink("npx", version)
  println(
    $|Now using Node.js \{version}
    #|Add this to your shell profile to use ntm:
    $|  export PATH="\{@util.get_bin_dir()}:$PATH"
    ,
  )
}
