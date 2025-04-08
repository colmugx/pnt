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
    ("install", "安装指定版本的 Node.js。", fn() { println("install") }),
    ("use", "切换到指定版本的 Node.js。", fn() { println("use") }),
    ("list", "列出已安装的 Node.js 版本。", fn() { println("list") }),
  ])
  app.execute(args)
}
