///|
#borrow(url)
extern "C" fn http_get_ffi(url : Bytes) -> Bytes? = "zig_http_get"

///|
pub fn get(url : String) -> String? {
  guard http_get_ffi(url.to_cstr()) is Some(res) else { None }
  res.from_cstr()
}

///|
#borrow(url, file)
extern "C" fn download_file_ffi(
  url : Bytes,
  file : Bytes,
  callback : FuncRef[(UInt64, UInt64) -> Unit]
) -> Unit? = "zig_download_file"

///|
pub fn download(url : String, file : String) -> Unit? {
  download_file_ffi(url.to_cstr(), file.to_cstr(), fn(current, total) {
    print_ffi(
      "Downloading: \{sprint(current.to_double()/total.to_double(), 2)}%",
    )
    if current == total {
      println("")
    }
  })
}

///|
#borrow(target, symlink)
extern "C" fn create_symlink_ffi(target : Bytes, symlink : Bytes) -> Unit = "zig_create_symlink"

///|
pub fn create_symlink(target : String, symlink : String) -> Unit {
  create_symlink_ffi(target.to_cstr(), symlink.to_cstr())
}

///|
#borrow(symlink)
extern "C" fn read_link_ffi(symlink : Bytes) -> Bytes = "zig_read_link"

///|
pub fn read_link(symlink : String) -> String {
  let str = symlink |> String::to_cstr |> read_link_ffi |> Bytes::from_cstr
  str.or_default()
}

///|
#borrow(dir)
extern "C" fn remove_dir_ffi(dir : Bytes) -> Unit? = "zig_remove_dir"

///|
priv type! RemoveDirError

///|
pub fn remove_dir(dir : String) -> Unit! {
  if remove_dir_ffi(dir.to_cstr()).is_empty() {
    raise RemoveDirError
  }
}

///|
extern "C" fn get_arch_ffi() -> Bytes? = "zig_get_arch"

///|
pub fn get_arch() -> String {
  get_arch_ffi().or_default().from_cstr().or_default()
}

///|
extern "C" fn get_os_ffi() -> Bytes? = "zig_get_os"

///|
pub fn get_os() -> String {
  get_os_ffi().or_default().from_cstr().or_default()
}

///|
#borrow(str)
extern "C" fn print_ffi(str : String) -> Unit = "zig_print"
