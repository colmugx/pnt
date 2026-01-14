///|
pub fn get_home() -> String {
  let env_map = @sys.get_env_vars()
  env_map.get("HOME").unwrap_or("")
}

///|
pub fn get_app_dir() -> String {
  let home = get_home()
  "\{home}/.local/share/pnt"
}

///|
pub fn create_dir(dir : String) -> Unit raise {
  if @fs.path_exists(dir) {
    return
  }
  @fs.create_dir(dir)
}

///|
pub fn download_file(
  url : String,
  file : String,
  callback~ : FuncRef[(UInt64, UInt64) -> Unit],
) -> Unit? {
  @ffi.download(url, file, callback)
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
    @fs.remove_file(symlink_path) catch {
      _ => ()
    }
  }
  @ffi.create_symlink(target_path, symlink_path) catch {
    _ => println("Failed to create symlink for \{binary}")
  }
}

///|
pub fn get_arch() -> String {
  @ffi.get_arch()
}

///|
pub fn get_os() -> String {
  @ffi.get_os()
}
