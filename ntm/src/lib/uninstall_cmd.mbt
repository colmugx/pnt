///|
let uninstall_cmd : @mug.Command = @mug.Command::new(
  "uninstall", "Uninstall a specific version of Node.js.", uninstall_action,
)

///|
fn uninstall_action(_ : @mug.Command, args : @mug.TArgs) -> Unit {
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
