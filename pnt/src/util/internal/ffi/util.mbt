///|
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * 100.00.pow(digits.to_double())).floor() / 100.00
  }
}

///|
priv trait TCStrToString {
  from_c_str(Self) -> String?
}

///|
priv trait TStringToCStr {
  to_c_str(Self) -> Bytes
}

///|
impl TCStrToString for Bytes with from_c_str(self) {
  let decoder = @encoding.decoder(@encoding.UTF8)
  guard decoder.decode?(self) is Ok(str) else { None }
  Some(str)
}

///|
impl TStringToCStr for String with to_c_str(self) {
  @encoding.encode(@encoding.UTF8, self)
}
