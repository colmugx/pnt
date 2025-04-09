///| 选项或标志
struct Flag {
  name : String
  short : String?
  description : String
}

///|
pub fn Flag::new(name : String, description : String, short~ : String? = None) -> Flag {
  { name, short, description }
}
