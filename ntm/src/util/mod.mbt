///|
type! ReadModError String

///|
pub fn get_version() -> String? {
  guard read_config?() is Ok(data) else { None }
  match data {
    { "version": String(ver), .. } => Some(ver)
    _ => None
  }
}

///|
pub fn read_config() -> Json!ReadModError {
  guard @json.parse?(resource) is Ok(json_data) else {
    raise ReadModError("JSON Parse Failed.")
  }
  json_data
}
