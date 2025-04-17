///|
let list_cmd : @mug.Command = @mug.Command::new(
  (
    "list", "List all installed Node.js versions, showing the currently active version.",
    list_action,
  ),
)

///|
fn list_action(_ : @mug.Command, _ : @mug.TArgs) -> Unit {
  let list = @util.list_node().rev()
  list.each(fn {
    item =>
      if @util.get_current_version() is Some(current) && item == current {
        println("* \{item}")
      } else {
        println("  \{item}")
      }
  })
}
