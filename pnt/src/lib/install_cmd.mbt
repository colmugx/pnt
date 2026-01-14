///|
priv suberror VersionError

///|
priv struct InstallCmd {
  name : String
  description : String
}

///|
/// 获取版本号
async fn install_get_version(tag : String) -> String {
  guard tag is "lts" || tag is "latest" else { @util.normalize_version(tag) }
  let list = @util.fetch_list() catch { _ => [] }
  match tag {
    "lts" => {
      guard list
        .iter()
        .find_first(fn(item) {
          if item.lts is String(s) {
            not(s.is_empty())
          } else {
            false
          }
        })
        is Some(latest_lts)
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
impl @mug_cli.TCommand for InstallCmd with execute(_, args) {
  ignore(args)
  println("Error: install command requires async context")
}

///|
impl @mug_cli.TCommand for InstallCmd with execute_async(_, args) {
  let base_url = "https://nodejs.org/dist"
  let version = install_get_version(args[0])
  if version.is_empty() {
    println(@mug_ansi.red("Error fetching available versions."))
    return
  }
  if @util.is_version_installed(version) {
    println(@mug_ansi.yellow("Node.js \{version} is already installed."))
    return
  }
  let tarball_name = @util.format_node_tarball(
    version~,
    os_tag=@util.get_os(),
    cpu_arch=@util.get_arch(),
  )
  let url = "\{base_url}/\{version}/\{tarball_name}"
  let dir = "\{@util.get_version_dir()}/\{version}"
  let pb = @mug.ProgressBar::new("Downloading", 0)
  global_download_pb.val = Some(pb)
  guard @util.download_file(url, dir, callback=fn(
      current : UInt64,
      total : UInt64,
    ) -> Unit {
      match global_download_pb.val {
        Some(pb) => {
          if pb.total == 0 && total > 0 {
            pb.set_total(total)
          }
          pb.set_position(current)
          if current == total {
            pb.finish()
            global_download_pb.val = None
          }
        }
        None => ()
      }
    })
    is Some(_) else {
    println(@mug_ansi.red("Error downloading Node.js \{version}."))
    return
  }
  println(@mug_ansi.green("Node.js \{version} installed successfully."))
}

///|
impl @mug_cli.TCommand for InstallCmd with name(self) {
  self.name
}

///|
impl @mug_cli.TCommand for InstallCmd with description(self) {
  self.description
}

///|
impl @mug_cli.TCommand for InstallCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let install_cmd : InstallCmd = {
  name: "install",
  description: "Install a specific version of Node.js. If version is \"lts\", the latest LTS version will be installed.",
}
