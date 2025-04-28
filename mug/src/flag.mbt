///| 选项或标志
pub struct Flag {
  name : String
  short : String?
  description : String
}

///|
pub fn Flag::new(
  name : String,
  description : String,
  short~ : String? = None
) -> Flag {
  { name, short, description }
}

///|
fn Flag::print_usage(self : Flag) -> Unit {
  println("  \{self.name} (\{self.short}) - \{self.description}")
}
