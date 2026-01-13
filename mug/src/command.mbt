///|
pub(open) trait HelpPrinter {
  print_usage(Self) -> Unit
}

///|
/// Flag error types for TFlaggable operations
pub(all) enum FlagError {
  NotFound(String)
  WrongType(String)
  UnexpectedBoolean(String)
} derive(Show, Eq, ToJson)

///|
/// Type-safe flag operations trait
pub(open) trait TFlaggable {
  /// Check if a flag was provided
  has_flag(Self, Array[String], String) -> Bool

  /// Get a string flag value
  get_flag_string(Self, Array[String], String) -> Result[String, FlagError]

  /// Get an int flag value
  get_flag_int(Self, Array[String], String) -> Result[Int, FlagError]

  /// Get a multiple-value flag
  get_flag_multiple(Self, Array[String], String) -> Array[String]

  /// Add a flag definition
  add_flag(Self, Flag) -> Unit

  /// Print flag help
  print_flag_help(Self) -> Unit
}

///|
/// Command trait with execute method
pub(open) trait TCommand: HelpPrinter {
  execute(Self, Array[String]) -> Unit
  async execute_async(Self, Array[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
}

///|
/// Type alias for command arguments
pub type TArgs = ArrayView[String]
