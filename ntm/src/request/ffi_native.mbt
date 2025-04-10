///|
extern "C" fn ffi_http_get(url : String) -> String = "zig_http_get"

///|
extern "C" fn ffi_download_file(url : String, file : String) -> Bool = "zig_download_file"

///|
extern "C" fn ffi_create_symlink(target : String, symlink : String) -> Unit = "zig_create_symlink"
