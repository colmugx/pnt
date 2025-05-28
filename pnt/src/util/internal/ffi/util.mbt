///|
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * 100.00.pow(digits.to_double())).floor() / 100.00
  }
}

///|
priv type ZigError

///|
extern "C" fn ZigError::get() -> ZigError = "zig_get_error"

///|
extern "C" fn ZigError::message(self : ZigError) -> Bytes = "zig_get_error_message"

///|
pub fn get_error_message() -> String {
  ZigError::get().message().from_cstr()
}
