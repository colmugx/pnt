///|
extern "C" fn http_get_ffi(url : Bytes) -> Bytes? = "zig_http_get"

///|
extern "C" fn download_file_ffi(
  url : Bytes,
  file : Bytes,
  callback : FuncRef[(UInt64, UInt64) -> Unit]
) -> Unit? = "zig_download_file"

///|
extern "C" fn create_symlink_ffi(target : Bytes, symlink : Bytes) -> Unit = "zig_create_symlink"

///|
extern "C" fn print_ffi(str : String) -> Unit = "zig_print"

extern "C" fn get_arch_ffi() -> Bytes? = "zig_get_arch"
