///|
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * 100.00.pow(digits.to_double())).floor() / 100.00
  }
}

///|
pub(open) trait FromCStr {
  from_cstr(Self) -> String?
}

///|
pub(open) trait ToCStr {
  to_cstr(Self) -> Bytes
}

///|
pub impl FromCStr for Bytes with from_cstr(self) {
  let decoder = @encoding.decoder(@encoding.UTF8)
  guard decoder.decode?(self) is Ok(str) else { None }
  Some(str)
}

///|
pub impl ToCStr for String with to_cstr(self) {
  @encoding.encode(@encoding.UTF8, self)
}

///|
extern "C" fn get_error_message_ffi() -> Bytes = "zig_get_error_message"

///|
pub fn get_error_message() -> String {
  return get_error_message_ffi().from_cstr().or("undefined error.")
}
