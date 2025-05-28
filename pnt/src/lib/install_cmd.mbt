///|
priv type! VersionError

///|
priv struct InstallCmd {
  name : String
  description : String
}

///| 获取版本号
fn get_version!(tag : String) -> String {
  guard tag is "lts" || tag is "latest" else { @util.normalize_version(tag) }
  let list = @util.fetch_list!()
  match tag {
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
    _ => raise VersionError
  }
}

///|
impl @mug.TCommand for InstallCmd with execute(_, args) {
  let base_url = "https://nodejs.org/dist"
  let version = get_version?(args[0]).or(String::default())
  if version.is_empty() {
    println("Error fetching available versions.")
    return
  }
  if @util.is_version_installed(version) {
    println("Node.js \{version} is already installed.")
    return
  }
  let tarball_name = @util.format_node_tarball(
    version~,
    os_tag=@util.get_os(),
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

///|
impl @mug.TCommand for InstallCmd with name(self) {
  self.name
}

///|
impl @mug.TCommand for InstallCmd with description(self) {
  self.description
}

///|
impl @mug.HelpPrinter for InstallCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let install_cmd : InstallCmd = {
  name: "install",
  description: "Install a specific version of Node.js. If version is \"lts\", the latest LTS version will be installed.",
}
