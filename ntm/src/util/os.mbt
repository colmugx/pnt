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

///|
pub fn download_file(url : String, file : String) -> Bool {
  @ffi.download(url, file)
}

///|
pub fn path_is_exist(path : String) -> Bool {
  @fs.path_exists(path)
}

///|
pub fn replace_symlink(binary : String, version : String) -> Unit {
  let version_bin_path = "\{get_version_dir()}/\{version}/bin"
  let target_path = "\{version_bin_path}/\{binary}"
  let symlink_path = "\{get_bin_dir()}/\{binary}"
  if @fs.path_exists(symlink_path) {
    @fs.remove_file?(symlink_path).unwrap()
  }
  @ffi.create_symlink(target_path, symlink_path)
}
