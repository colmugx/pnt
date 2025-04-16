///|
pub fn get(url : String) -> String? {
  guard http_get_ffi(string_encode_to_bytes(url)) is Some(res) else { None }
  bytes_dencode_to_string(res)
}

///|
pub fn download(url : String, file : String) -> Unit? {
  download_file_ffi(string_encode_to_bytes(url), string_encode_to_bytes(file), fn(
    current,
    total
  ) {
    print_ffi(
      "Downloading: \{sprint(current.to_double()/total.to_double(), 2)}%",
    )
    if current == total {
      println("")
    }
  })
}

///|
pub fn create_symlink(target : String, symlink : String) -> Unit {
  create_symlink_ffi(
    string_encode_to_bytes(target),
    string_encode_to_bytes(symlink),
  )
}

///|
pub fn get_arch() -> String {
  bytes_dencode_to_string(get_arch_ffi().or_default()).or_default()
}
