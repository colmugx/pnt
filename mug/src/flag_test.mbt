///|
test "Flag::new creates flag with name and description" {
  let flag = Flag::new("verbose", "Enable verbose output")
  inspect(flag.name, content="verbose")
  inspect(flag.description, content="Enable verbose output")
  inspect(flag.short is None, content="true")
}

///|
test "Flag::new with short option" {
  let flag = Flag::new("verbose", "Enable verbose output", short=Some("v"))
  inspect(flag.name, content="verbose")
  inspect(flag.short.unwrap_or(""), content="v")
}

///|
test "Flag::new with short=None explicitly" {
  let flag = Flag::new("quiet", "Suppress output", short=None)
  inspect(flag.name, content="quiet")
  inspect(flag.short is None, content="true")
}

///|
test "Flag with variable for short parameter" {
  let short_name = "o"
  let flag = Flag::new("output", "Output file", short=Some(short_name))
  inspect(flag.short.unwrap_or(""), content="o")
}
