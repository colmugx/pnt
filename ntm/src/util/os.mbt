///|
pub fn get_arch() -> String {
  let env_map = @sys.get_env_vars()

  // TODO：借用变量，最后得自己获取
  env_map.get("FNM_ARCH").or("")
}

///|
pub fn get_home() -> String {
  let env_map = @sys.get_env_vars()
  env_map.get("HOME").or("")
}

///|
pub fn get_app_dir() -> String {
  let home = get_home()
  "\{home}/.local/share/ntm"
}

///|
pub fn create_dir(dir : String) -> Unit! {
  if @fs.path_exists(dir) {
    return
  }

  @fs.create_dir!(dir)
}
