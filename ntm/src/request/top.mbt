///|
pub fn get(url : String) -> String {
  ffi_http_get(url)
}

///|
pub fn download(url : String, file : String) -> Bool {
  ffi_download_file(url, file)
}

///|
pub fn create_symlink(target : String, symlink : String) -> Unit {
  ffi_create_symlink(target, symlink)
}
