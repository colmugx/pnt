///|
extern "C" fn http_get_ffi(url : String) -> String = "zig_http_get"

///|
extern "C" fn download_file_ffi(url : String, file : String) -> Bool = "zig_download_file"

///|
extern "C" fn create_symlink_ffi(target : String, symlink : String) -> Unit = "zig_create_symlink"
