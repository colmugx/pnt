///| Flag types
pub enum FlagType {
  Boolean
  StringVal
  Int
  Multiple
} derive(Show, Eq, ToJson)

///| 选项或标志
pub struct Flag {
  name : String
  short : String?
  description : String
  flag_type : FlagType
  required : Bool
  default_value : String?
}

///|
pub fn Flag::new(
  name : String,
  description : String,
  short~ : String? = None,
  flag_type~ : FlagType = Boolean,
  required~ : Bool = false
) -> Flag {
  { name, short, description, flag_type, required, default_value: None }
}

///|
pub fn Flag::get_type(self : Flag) -> FlagType {
  self.flag_type
}

///|
pub fn Flag::get_short(self : Flag) -> String? {
  self.short
}

///|
fn Flag::print_usage(self : Flag) -> Unit {
  let short_str = match self.short {
    Some(s) => " (-\{s})"
    None => ""
  }
  println("  --\{self.name}\{short_str} - \{self.description}")
}
