///| 内置命令: version
pub(all) struct VersionCommand {
  app : App
}

///|
impl TCommand for VersionCommand with name(_) {
  "version"
}

///|
impl TCommand for VersionCommand with description(self) {
  self.app.i18n.t("version")
}

///|
impl TCommand for VersionCommand with execute(self, _) {
  self.app.print_version()
}

impl TCommand for VersionCommand with execute_async(self, args) {
  self.execute(args)
}

///|
impl HelpPrinter for VersionCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
}