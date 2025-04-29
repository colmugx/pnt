///|
priv struct UninstallCmd {
  name : String
  description : String
}

///|
impl @mug.TCommand for UninstallCmd with execute(_, args) {
  let version = args[0]
  if version.is_empty() {
    println("Illegal versions.")
    return
  }
  if not(@util.is_version_installed(version)) {
    println("Node.js \{version} is not installed.")
    return
  }
  guard @util.get_current_version() is Some(current) && current != version else {
    println(
      "Cannot uninstall the currently active version. Switch to another version first.",
    )
    return
  }
  if @util.remove_by_version?(version).is_err() {
    println("Error removing \{version}")
    return
  }
  println("Node.js \{version} uninstalled successfully")
}

///|
impl @mug.TCommand for UninstallCmd with name(self) {
  self.name
}

///|
impl @mug.TCommand for UninstallCmd with description(self) {
  self.description
}

///|
impl @mug.HelpPrinter for UninstallCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let uninstall_cmd : UninstallCmd = {
  name: "uninstall",
  description: "Uninstall a specific version of Node.js.",
}
