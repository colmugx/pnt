///|
pub suberror IOError {
  IOError(String)
} derive(Show)

///|
#borrow(target, link)
extern "C" fn pnt_symlink_ffi(target : Bytes, link : Bytes) -> Int = "pnt_symlink"

///|
pub fn create_symlink(target : String, symlink : String) -> Unit raise {
  let res = pnt_symlink_ffi(
    target |> ToCStr::to_cstr,
    symlink |> ToCStr::to_cstr,
  )
  if res != 0 {
    raise IOError("symlink failed")
  }
}

///|
#borrow(path, buf)
extern "C" fn pnt_readlink_ffi(path : Bytes, buf : Bytes, bufsize : Int) -> Int = "pnt_readlink"

///|
pub fn read_link(symlink : String) -> String raise {
  let buf = Bytes::new(1024)
  let len = pnt_readlink_ffi(symlink |> ToCStr::to_cstr, buf, 1024)
  if len < 0 {
    raise IOError("readlink failed")
  }
  buf.to_string()[:len].to_string()
}

///|
extern "C" fn pnt_get_arch_ffi() -> Bytes = "pnt_get_arch"

///|
pub fn get_arch() -> String {
  pnt_get_arch_ffi() |> FromCStr::from_cstr
}

///|
extern "C" fn pnt_get_os_ffi() -> Bytes = "pnt_get_os"

///|
pub fn get_os() -> String {
  pnt_get_os_ffi() |> FromCStr::from_cstr
}

///|
#borrow(rows, cols)
extern "C" fn pnt_get_term_size_ffi(
  rows : Array[Int],
  cols : Array[Int],
) -> Int = "pnt_get_term_size"

///|
pub fn get_term_size() -> (Int, Int)? {
  let rows = [0]
  let cols = [0]
  if pnt_get_term_size_ffi(rows, cols) == 0 {
    Some((rows[0], cols[0]))
  } else {
    None
  }
}

///|
extern "C" fn pnt_is_interactive_ffi() -> Int = "pnt_is_interactive"

///|
pub fn is_interactive() -> Bool {
  pnt_is_interactive_ffi() != 0
}

///|
#borrow(str)
extern "C" fn print_ffi(str : String) -> Unit = "zig_print"

///|
#borrow(url, file)
extern "C" fn download_file_ffi(
  url : Bytes,
  file : Bytes,
  callback : FuncRef[(UInt64, UInt64) -> Unit],
) -> Unit? = "zig_download_file"

///|
pub fn download(url : String, file : String) -> Unit? {
  download_file_ffi(url |> ToCStr::to_cstr, file |> ToCStr::to_cstr, fn(
    current,
    total,
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
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * @math.pow(100.0, digits.to_double())).floor() / 100.0
  }
}

///|
priv type ZigError

///|
extern "C" fn ZigError::get() -> ZigError = "zig_get_error"

///|
#borrow(err)
extern "C" fn ZigError::message(err : ZigError) -> Bytes = "zig_get_error_message"

///|
pub fn get_error_message() -> String {
  ZigError::get().message() |> FromCStr::from_cstr
}
