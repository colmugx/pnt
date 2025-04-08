///|
pub fn execute(app_name : String, args : ArrayView[String]) -> Unit {
  let app = @mug.App::new(app_name, "Node Tool in Moonbit")
  
  let install_cmd = @mug.Command::new("install", "安装指定版本的 Node.js。")
  let use_cmd = @mug.Command::new("use", "切换到指定版本的 Node.js。")
  let list_cmd = @mug.Command::new("list", "列出已安装的 Node.js 版本。")

  app.add_command(install_cmd)
  app.add_command(use_cmd)
  app.add_command(list_cmd)

  app.execute(args)
}
