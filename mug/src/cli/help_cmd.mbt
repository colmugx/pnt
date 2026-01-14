///|
pub(all) struct HelpCommand {
  app : App
}

///|
impl TCommand for HelpCommand with name(_) {
  "help"
}

///|
impl TCommand for HelpCommand with description(self) {
  self.app.i18n.t("help")
}

///|
impl TCommand for HelpCommand with execute(self, _) {
  self.app.print_help()
}

///|
impl TCommand for HelpCommand with execute_async(self, args) {
  self.execute(args)
}

///|
impl TCommand for HelpCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
