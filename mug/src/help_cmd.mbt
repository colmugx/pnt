priv struct HelpCommand {
  app: App
}

impl TCommand for HelpCommand with name(_) {
  "help"
}

impl TCommand for HelpCommand with description(_) {
  "Show help information"
}

impl TCommand for HelpCommand with execute(self, _) {
  self.app.print_help()
}

impl HelpPrinter for HelpCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}
