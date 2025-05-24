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
