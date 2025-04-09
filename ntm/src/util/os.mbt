///|
pub fn get_arch() -> String {
  let env_map = @sys.get_env_vars()

  // TODO：借用变量，最后得自己获取
  env_map.get("FNM_ARCH").or("")
}
