///|
pub fn execute(_ : String, args : ArrayView[String]) -> Unit {
  let app = @mug.App::new(
    "ntm",
    "Node Tool in Moonbit",
    version=@util.get_version(),
  )
  app.add_command(list_remote_cmd)
  app.add_command(install_cmd)
  app.add_command(use_cmd)
  app.execute(args)
}

///|
fn init {
  [@util.get_app_dir(), @util.get_version_dir(), @util.get_bin_dir()].each(fn {
    item => @util.create_dir?(item).unwrap()
  })
}
