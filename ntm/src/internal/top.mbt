///|
priv struct Config {
  name : String
  description : String
}

///|
pub fn execute(app : String, args : ArrayView[String]) -> Unit {
  let app_config = { name: "ntm", description: "Node Tool in Moonbit" }
  let app = @mug.App::new(app_config.name, app_config.description)
  app.register([
    ("install", "安装指定版本的 Node.js。", fn(_) { println("install") }),
    ("use", "切换到指定版本的 Node.js。", fn(_) { println("use") }),
  ])

  app.add_command(list_remote_cmd)
  app.execute(args)
}
