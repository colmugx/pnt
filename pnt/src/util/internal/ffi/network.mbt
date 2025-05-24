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
