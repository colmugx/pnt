///|
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * 100.00.pow(digits.to_double())).floor() / 100.00
  }
}

///|
extern "C" fn get_error_message_ffi() -> Bytes = "zig_get_error_message"

///|
pub fn get_error_message() -> String {
  return get_error_message_ffi().from_cstr()
}
