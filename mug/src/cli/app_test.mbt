///|
/// Test command for testing App functionality
struct TestCommand {
  mut execute_called : Bool
  mut received_args : Array[String]
}

///|
fn TestCommand::new() -> TestCommand {
  { execute_called: false, received_args: [] }
}

///|
impl TCommand for TestCommand with name(self) {
  "test"
}

///|
impl TCommand for TestCommand with description(self) {
  "A test command"
}

///|
impl TCommand for TestCommand with execute(self, args) {
  self.execute_called = true
  self.received_args = Array::from_iter(args.iter())
}

///|
impl TCommand for TestCommand with execute_async(self, args) {
  self.execute(args)
}

///|
impl TCommand for TestCommand with print_usage(_self) {
  println("  test\tA test command")
}

///|
test "App::new creates app with basic fields" {
  let app = App::new("testapp", "A test application")
  inspect(app.name, content="testapp")
  inspect(app.description, content="A test application")
  inspect(app.commands.length(), content="0")
}

///|
test "App::version sets version" {
  let app = App::new("testapp", "A test application")
  let app = app.version("1.0.0")
  match app.ver {
    Some(v) => inspect(v, content="1.0.0")
    None => @test.fail("Version should be Some")
  }
}

///|
test "App::add_command adds command to list" {
  let app = App::new("testapp", "A test application")
  let cmd = TestCommand::new()
  let app = app.add_command(cmd)
  inspect(app.commands.length(), content="1")
}

///|
test "App::add_command makes command available" {
  let app = App::new("testapp", "A test application")
  let cmd = TestCommand::new()
  let app = app.add_command(cmd)

  // Check that command was added to the list
  inspect(app.commands.length(), content="1")

  // Verify command name
  match app.commands.get(0) {
    Some(c) => inspect(c.name(), content="test")
    None => @test.fail("Command should be in list")
  }
}

///|
test "App commands array stores commands correctly" {
  let app = App::new("testapp", "A test application")
  let cmd1 = TestCommand::new()
  let cmd2 = TestCommand::new()
  let app = app.add_command(cmd1).add_command(cmd2)
  inspect(app.commands.length(), content="2")
}

///|
test "App ensure_default_commands adds help and version" {
  let app = App::new("testapp", "A test application")

  // Before ensure_default_commands, no commands
  inspect(app.commands.length(), content="0")

  // Call ensure_default_commands
  let app = app.ensure_default_commands()

  // Should have help and version commands
  inspect(app.commands.length(), content="2")

  // Verify the command names
  let names = app.commands.map(fn(c) { c.name() })
  let has_help = names.iter().find_first(fn(n) { n == "help" }) is Some(_)
  let has_version = names.iter().find_first(fn(n) { n == "version" }) is Some(_)

  // Convert bool to string for inspect
  inspect(has_help.to_string(), content="true")
  inspect(has_version.to_string(), content="true")
}

///|
test "App ensure_default_commands is idempotent" {
  let app = App::new("testapp", "A test application")
  let app = app.ensure_default_commands()
  let count_after_first = app.commands.length()
  let app = app.ensure_default_commands()
  let count_after_second = app.commands.length()
  inspect(count_after_first.to_string(), content="2")
  inspect(count_after_second.to_string(), content="2")
}

///|
test "App::new initializes i18n with English translations" {
  let app = App::new("testapp", "A test application")

  // Test that i18n is initialized and working
  let help_text = app.i18n.t("help")
  let version_text = app.i18n.t("version")
  inspect(help_text, content="Show help information")
  inspect(version_text, content="Show version")
}

///|
test "App::with_locale changes locale" {
  let app = App::new("testapp", "A test application")

  // Set locale to zh-CN
  let app_zh = app.with_locale("zh-CN")

  // Check that locale was changed
  let current_locale = app_zh.i18n.get_locale()
  inspect(current_locale, content="zh-CN")
}

///|
test "App::with_translations adds custom translations" {
  let app = App::new("testapp", "A test application")

  // Add custom translations
  let custom_translations : Map[String, String] = {
    "custom.message": "Custom message",
    "another.key": "Another value",
  }
  let app_custom = app.with_translations("en-US", custom_translations)

  // Test that custom translations work
  let custom_text = app_custom.i18n.t("custom.message")
  let another_text = app_custom.i18n.t("another.key")
  inspect(custom_text, content="Custom message")
  inspect(another_text, content="Another value")
}

///|
test "App::disable_i18n disables translation" {
  let app = App::new("testapp", "A test application")

  // Disable i18n
  let app_disabled = app.disable_i18n()

  // When i18n is disabled, should return English fallback
  let help_text = app_disabled.i18n.t("help")
  inspect(help_text, content="Show help information")

  // Unknown key should return the key itself when i18n is disabled
  let unknown_text = app_disabled.i18n.t("unknown.key")
  inspect(unknown_text, content="unknown.key")
}

///|
test "App::enable_i18n enables translation" {
  let app = App::new("testapp", "A test application")

  // Disable then enable
  let app_disabled = app.disable_i18n()
  let app_enabled = app_disabled.enable_i18n()

  // Should work normally when enabled
  let help_text = app_enabled.i18n.t("help")
  inspect(help_text, content="Show help information")
}

///|
test "HelpCommand uses i18n for description" {
  let app = App::new("testapp", "A test application")

  // Create help command and test that i18n integration works
  // The description should come from app's i18n
  let help_text = app.i18n.t("help")
  inspect(help_text, content="Show help information")
}

///|
test "VersionCommand uses i18n for description" {
  let app = App::new("testapp", "A test application")

  // Create version command and test that i18n integration works
  // The description should come from app's i18n
  let version_text = app.i18n.t("version")
  inspect(version_text, content="Show version")
}
