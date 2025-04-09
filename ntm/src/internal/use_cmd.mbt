///|

///|
pub let use_cmd : @mug.Command = @mug.Command::new(
  (
    "use", "Switch to a specific version of Node.js. If version is \"lts\", the latest installed LTS version will be used.",
    use_action,
  ),
)

///|
fn use_action(c : @mug.Command, args : @mug.TArgs) -> Unit {
  match args {
    ["lts", ..] => {
      println("find lts")
    }
    _ => ignore(())
  }
}
