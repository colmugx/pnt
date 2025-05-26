///|
pub(open) trait FromCStr {
  from_cstr(Self) -> String
}

///|
pub(open) trait ToCStr {
  to_cstr(Self) -> Bytes
}

///|
pub impl FromCStr for Bytes with from_cstr(self) {
  let decoder = @encoding.decoder(@encoding.UTF8)
  guard decoder.decode?(self) is Ok(str) else { "" }
  str
}

///|
pub impl ToCStr for String with to_cstr(self) {
  @encoding.encode(@encoding.UTF8, self)
}
