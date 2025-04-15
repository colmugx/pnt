///|
extern "C" fn http_get_ffi(url : Bytes) -> Bytes? = "zig_http_get"

///|
extern "C" fn download_file_ffi(url : Bytes, file : Bytes) -> Unit? = "zig_download_file"

///|
extern "C" fn create_symlink_ffi(target : Bytes, symlink : Bytes) -> Unit = "zig_create_symlink"
