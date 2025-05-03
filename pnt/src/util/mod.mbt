///|
type! ReadModError String

///|
pub fn get_version() -> String {
  let default = ""
  guard read_config?() is Ok(data) else { default }
  match data {
    { "version": String(ver), .. } => ver
    _ => default
  }
}

///|
pub fn read_config() -> Json!ReadModError {
  guard @json.parse?(mod_config) is Ok(json_data) else {
    raise ReadModError("JSON Parse Failed.")
  }
  json_data
}
