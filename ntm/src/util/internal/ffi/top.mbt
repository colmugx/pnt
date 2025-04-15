///|
pub fn get(url : String) -> String? {
  guard http_get_ffi(encoding(url)) is Some(res) else { None }
  guard @encoding.decoder(@encoding.UTF8).decode?(res) is Ok(s) else { None }
  Some(s)
}

///|
pub fn download(url : String, file : String) -> Unit? {
  download_file_ffi(encoding(url), encoding(file), fn(current, total) {
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
  create_symlink_ffi(encoding(target), encoding(symlink))
}

///|
fn encoding(str : String) -> Bytes {
  @encoding.encode(@encoding.UTF8, str)
}

///|
fn sprint(num : Double, digits : Int) -> Double {
  if num == 0 {
    num
  } else {
    let base = 100.00
    (num * base.pow(digits.to_double())).floor() / base
  }
}
