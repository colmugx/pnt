///|
/// Parsed command line arguments
pub struct ParsedArgs {
  positional : Array[String]
  flags : Map[String, FlagValue]
}

///|
/// Flag values with type safety
pub enum FlagValue {
  Boolean(Bool)
  StringVal(String)
  Int(Int)
  Multiple(Array[String])
} derive(Show, Eq, ToJson)

///|
/// Parse error types
pub enum ParseError {
  UnknownFlag(String)
  MissingValue(String)
  InvalidInt(String, String) // (flag_name, value)
  UnexpectedValue(String, String) // (flag_name, value)
} derive(Show, Eq)

///|
/// Parse command line arguments
pub fn parse_args(
  args : Array[String],
  flags : Map[String, Flag],
) -> Result[ParsedArgs, ParseError] {
  let result = parse_args_internal(args, flags)
  result
}

///|
/// Internal parsing function
fn parse_args_internal(
  args : Array[String],
  flags : Map[String, Flag],
) -> Result[ParsedArgs, ParseError] {
  let positional_list : Array[String] = []
  let mut parsed_flags : Map[String, FlagValue] = Map::new()
  let mut i = 0
  while i < args.length() {
    let arg = args[i]
    if arg.length() > 1 && arg[0] == '-' && arg[1] == '-' {
      // Long flag: --flag or --flag:value
      let flag_part = substring(arg, 2, arg.length())
      let colon_idx = find_char_index(flag_part, ':')
      match colon_idx {
        Some(idx) => {
          // --flag:value format
          let flag_name = substring(flag_part, 0, idx)
          let flag_value = substring(flag_part, idx + 1, flag_part.length())
          match add_parsed_flag(flag_name, flag_value, flags, parsed_flags) {
            Ok(new_flags) => parsed_flags = new_flags
            Err(e) => return Err(e)
          }
        }
        None =>
          // Check if it's a boolean flag
          match flags.get(flag_part) {
            Some(flag_def) => {
              let flag_type = Flag::get_type(flag_def)
              if flag_type == FlagType::Boolean {
                parsed_flags[flag_part] = FlagValue::Boolean(true)
                // Need a value, check next arg
              } else if i + 1 < args.length() {
                let next_arg = args[i + 1]
                if next_arg.length() == 0 || next_arg[0] != '-' {
                  match
                    add_parsed_flag(flag_part, next_arg, flags, parsed_flags) {
                    Ok(new_flags) => parsed_flags = new_flags
                    Err(e) => return Err(e)
                  }
                  i = i + 1
                } else {
                  return Err(ParseError::MissingValue(flag_part))
                }
              } else {
                return Err(ParseError::MissingValue(flag_part))
              }
            }
            None => return Err(ParseError::UnknownFlag(flag_part))
          }
      }
    } else if arg.length() > 1 && arg[0] == '-' {
      // Short flag: -f or -f value
      let short_flag = substring(arg, 1, arg.length())

      // Find the flag name from short form
      let found_name = find_flag_by_short(short_flag, flags)
      match found_name {
        Some(flag_name) => {
          let flag_def = flags[flag_name]
          let flag_type = Flag::get_type(flag_def)
          if flag_type == FlagType::Boolean {
            parsed_flags[flag_name] = FlagValue::Boolean(true)
            // Need a value, check next arg
          } else if i + 1 < args.length() {
            let next_arg = args[i + 1]
            if next_arg.length() == 0 || next_arg[0] != '-' {
              match add_parsed_flag(flag_name, next_arg, flags, parsed_flags) {
                Ok(new_flags) => parsed_flags = new_flags
                Err(e) => return Err(e)
              }
              i = i + 1
            } else {
              return Err(ParseError::MissingValue(flag_name))
            }
          } else {
            return Err(ParseError::MissingValue(flag_name))
          }
        }
        None => return Err(ParseError::UnknownFlag(short_flag))
      }
    } else {
      // Positional argument
      positional_list.push(arg)
    }
    i = i + 1
  }
  Ok({ positional: positional_list, flags: parsed_flags })
}

///|
/// Add a parsed flag to the map
fn add_parsed_flag(
  flag_name : String,
  value : String,
  flags : Map[String, Flag],
  parsed_flags : Map[String, FlagValue],
) -> Result[Map[String, FlagValue], ParseError] {
  match flags.get(flag_name) {
    Some(flag_def) => {
      let flag_type = Flag::get_type(flag_def)
      match flag_type {
        FlagType::Boolean => Err(ParseError::UnexpectedValue(flag_name, value))
        FlagType::StringVal => {
          let new_flags = parsed_flags
          new_flags[flag_name] = FlagValue::StringVal(value)
          Ok(new_flags)
        }
        FlagType::Int =>
          match parse_int(value) {
            Some(int_val) => {
              let new_flags = parsed_flags
              new_flags[flag_name] = FlagValue::Int(int_val)
              Ok(new_flags)
            }
            None => Err(ParseError::InvalidInt(flag_name, value))
          }
        FlagType::Multiple =>
          match parsed_flags.get(flag_name) {
            Some(FlagValue::Multiple(arr)) => {
              // Build new array with appended value
              let new_arr : Array[String] = []
              for v in arr {
                new_arr.push(v)
              }
              new_arr.push(value)
              let new_flags = parsed_flags
              new_flags[flag_name] = FlagValue::Multiple(new_arr)
              Ok(new_flags)
            }
            _ => {
              let new_flags = parsed_flags
              new_flags[flag_name] = FlagValue::Multiple([value])
              Ok(new_flags)
            }
          }
      }
    }
    None => Err(ParseError::UnknownFlag(flag_name))
  }
}

///|
/// Find flag name by short form
fn find_flag_by_short(short : String, flags : Map[String, Flag]) -> String? {
  let mut result : String? = None
  let keys = flags.keys().to_array()
  let mut i = 0
  while i < keys.length() {
    let name = keys[i]
    let flag_def = flags[name]
    let short_opt = Flag::get_short(flag_def)
    match short_opt {
      Some(s) if s == short => result = Some(name)
      _ => ()
    }
    i = i + 1
  }
  result
}

///|
/// Find character index in string
fn find_char_index(s : String, c : Char) -> Int? {
  s.find_by(fn(ch) { ch == c })
}

///|
/// Get substring - using StringBuilder for efficiency
fn substring(s : String, start : Int, end : Int) -> String {
  let sb = StringBuilder::new()
  let end_idx = if end > s.length() { s.length() } else { end }
  for i = start; i < end_idx; i = i + 1 {
    sb.write_char(s.get_char(i).unwrap())
  }
  sb.to_string()
}

///|
/// Parse integer from string
fn parse_int(s : String) -> Int? {
  Some(@strconv.parse_int(s[:])) catch {
    _ => None
  }
}

///|
/// Get positional arguments from parsed result
pub fn ParsedArgs::get_positional(self : ParsedArgs) -> Array[String] {
  self.positional
}

///|
/// Check if a flag was provided
pub fn ParsedArgs::has_flag(self : ParsedArgs, flag_name : String) -> Bool {
  self.flags.contains(flag_name)
}

///|
/// Get a boolean flag value (defaults to false if not present)
pub fn ParsedArgs::get_bool(self : ParsedArgs, flag_name : String) -> Bool {
  match self.flags.get(flag_name) {
    Some(FlagValue::Boolean(b)) => b
    _ => false
  }
}

///|
/// Get a string flag value
pub fn ParsedArgs::get_string(
  self : ParsedArgs,
  flag_name : String,
) -> Result[String, String] {
  match self.flags.get(flag_name) {
    Some(FlagValue::StringVal(s)) => Ok(s)
    Some(FlagValue::Boolean(_)) =>
      Err("Expected string flag, got boolean".to_string())
    Some(FlagValue::Int(_)) => Err("Expected string flag, got int".to_string())
    Some(FlagValue::Multiple(_)) =>
      Err("Expected string flag, got multiple".to_string())
    None => Err("Flag not found: \{flag_name}".to_string())
  }
}

///|
/// Get an int flag value
pub fn ParsedArgs::get_int(
  self : ParsedArgs,
  flag_name : String,
) -> Result[Int, String] {
  match self.flags.get(flag_name) {
    Some(FlagValue::Int(i)) => Ok(i)
    Some(FlagValue::StringVal(s)) =>
      match parse_int(s) {
        Some(i) => Ok(i)
        None => Err("Cannot convert to int".to_string())
      }
    Some(_) => Err("Expected int flag".to_string())
    None => Err("Flag not found: \{flag_name}".to_string())
  }
}

///|
/// Get a multiple-value flag
pub fn ParsedArgs::get_multiple(
  self : ParsedArgs,
  flag_name : String,
) -> Array[String] {
  match self.flags.get(flag_name) {
    Some(FlagValue::Multiple(arr)) => arr
    _ => []
  }
}
