///|
fn sprint(num : Double, digits : Int) -> Double {
  match num {
    0 => num
    x => (x * 100.00.pow(digits.to_double())).floor() / 100.00
  }
}

///|
fn string_encode_to_bytes(str : String) -> Bytes {
  @encoding.encode(@encoding.UTF8, str)
}

///|
fn bytes_dencode_to_string(bytes : Bytes) -> String? {
  let decoder = @encoding.decoder(@encoding.UTF8)
  match decoder.decode?(bytes) {
    Ok(str) => Some(str)
    _ => None
  }
}
