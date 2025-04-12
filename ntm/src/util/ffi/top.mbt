///|
pub fn get(url : String) -> String? {
  http_get_ffi(url)
}

///|
pub fn download(url : String, file : String) -> Bool {
  download_file_ffi(url, file)
}

///|
pub fn create_symlink(target : String, symlink : String) -> Unit {
  create_symlink_ffi(target, symlink)
}
