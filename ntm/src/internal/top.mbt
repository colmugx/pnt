///|
priv struct Config {
  name : String
  description : String
}

///|
pub fn execute(app : String, args : ArrayView[String]) -> Unit {
  let app_config = { name: "ntm", description: "Node Tool in Moonbit" }
  let app = @mug.App::new(app_config.name, app_config.description)
  app.add_command(list_remote_cmd)
  app.add_command(install_cmd)
  app.execute(args)
}

///|
fn init {
  @util.create_dir?(@util.get_app_dir()).unwrap()
  @util.create_dir?(@util.get_version_dir()).unwrap()
  @util.create_dir?(@util.get_bin_dir()).unwrap()
}
