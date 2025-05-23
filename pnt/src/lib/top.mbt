///|
pub fn execute(args : ArrayView[String]) -> Unit {
  @mug.App::new("pnt", "Pico NodeJS Toolkit")
  ..version(@util.get_version())
  ..add_command(list_cmd)
  ..add_command(list_remote_cmd)
  ..add_command(install_cmd)
  ..add_command(use_cmd)
  ..add_command(uninstall_cmd)
  ..execute(args)
}

///|
fn init {
  [@util.get_app_dir(), @util.get_version_dir(), @util.get_bin_dir()].each(fn {
    item => @util.create_dir?(item).unwrap()
  })
}
