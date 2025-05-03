///| 内置命令: version 
priv struct VersionCommand {
  app : App
}

///|
impl TCommand for VersionCommand with name(_) {
  "version"
}

///|
impl TCommand for VersionCommand with description(_) {
  "Show version"
}

///|
impl TCommand for VersionCommand with execute(self, _) {
  self.app.print_version()
}

///|
impl HelpPrinter for VersionCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}