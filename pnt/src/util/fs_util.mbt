///|
pub fn remove_all(path : String) -> Unit raise {
  if not(@fs.path_exists(path)) {
    return
  }
  if @fs.is_dir(path) {
    let entries = @fs.read_dir(path)
    for entry in entries {
      let child_path = if path.has_suffix("/") {
        "\{path}\{entry}"
      } else {
        "\{path}/\{entry}"
      }
      remove_all(child_path)
    }
    @fs.remove_dir(path)
  } else {
    @fs.remove_file(path)
  }
}
