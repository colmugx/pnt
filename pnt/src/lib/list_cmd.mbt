///|
priv struct ListCmd {
  name : String
  description : String
}

///|
impl @mug.TCommand for ListCmd with execute(_, _) {
  let list = @util.list_node().rev()
  list.each(fn(item) {
    if @util.get_current_version() is Some(current) && item[:] == current {
      println("* \{item}")
    } else {
      println("  \{item}")
    }
  })
}

///|
impl @mug.TCommand for ListCmd with execute_async(self, args) {
  self.execute(args)
}

///|
impl @mug.TCommand for ListCmd with name(self) {
  self.name
}

///|
impl @mug.TCommand for ListCmd with description(self) {
  self.description
}

///|
impl @mug.TCommand for ListCmd with print_usage(self) {
  println("  \{self.name} - \{self.description}")
}

///|
let list_cmd : ListCmd = {
  name: "list",
  description: "List all installed Node.js versions, showing the currently active version.",
}
