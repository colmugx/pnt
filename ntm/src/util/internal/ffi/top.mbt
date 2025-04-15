///|
pub fn get(url : String) -> String? {
  guard http_get_ffi(encoding(url)) is Some(res) else { None }
  guard @encoding.decoder(@encoding.UTF8).decode?(res) is Ok(s) else { None }
  Some(s)
}

///|
pub fn download(url : String, file : String) -> Unit? {
  download_file_ffi(encoding(url), encoding(file))
}

///|
pub fn create_symlink(target : String, symlink : String) -> Unit {
  create_symlink_ffi(encoding(target), encoding(symlink))
}

///|
fn encoding(str : String) -> Bytes {
  @encoding.encode(@encoding.UTF8, str)
}
