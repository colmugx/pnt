///|
suberror ReadModError {
  ReadModError(String)
}

///|
pub fn get_version() -> String {
  let default = ""
  let data = try? read_config()
  match data {
    Ok(json) =>
      match json {
        { "version": String(ver), .. } => ver
        _ => default
      }
    Err(_) => default
  }
}

///|
pub fn read_config() -> Json raise ReadModError {
  @json.parse(mod_config) catch {
    _ => raise ReadModError("JSON Parse Failed.")
  }
}
