///|
let install_cmd : @mug.Command = @mug.Command::new(
  (
    "install", "Install a specific version of Node.js. If version is \"lts\", the latest LTS version will be installed.",
    install_action,
  ),
)

///| 获取版本号
fn get_version(version_arg : String, list : Array[@util.RemoteNode]) -> String {
  match version_arg {
    "lts" => {
      let latest_lts = list
        .iter()
        .find_first(fn {
          item =>
            item.lts.as_string().map_or(false, fn { s => not(s.is_empty()) })
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
    str => @util.normalize_version(str)
  }
}

///|
fn install_action(_ : @mug.Command, args : @mug.TArgs) -> Unit {
  let base_url = "https://nodejs.org/dist"
  let list = @util.fetch_list?().or([])
  let version = get_version(args[0], list)
  if version.is_empty() {
    println("Error fetching available versions.")
    return
  }
  if @util.is_version_installed(version) {
    println("Node.js \{version} is already installed.")
    return
  }

  // TODO: 获取系统
  let tarball_name = @util.format_node_tarball(
    version~,
    os_tag="darwin",
    cpu_arch=@util.get_arch(),
  )
  let url = "\{base_url}/\{version}/\{tarball_name}"
  let dir = "\{@util.get_version_dir()}/\{version}"
  println("Downloading \{tarball_name}...")
  guard @util.download_file(url, dir) is Some(_) else {
    println("Error downloading Node.js \{version}.")
    return
  }
  println("Node.js \{version} installed successfully.")
}
