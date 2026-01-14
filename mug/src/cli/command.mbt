///|
/// Command trait with execute method and help printing
pub(open) trait TCommand {
  execute(Self, ArrayView[String]) -> Unit
  async execute_async(Self, ArrayView[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
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
  get_flag_string(Self, Array[String], String) -> Result[String, FlagError]
  get_flag_int(Self, Array[String], String) -> Result[Int, FlagError]
  get_flag_multiple(Self, Array[String], String) -> Array[String]
  print_flag_help(Self) -> Unit
}

///|
pub type TArgs = ArrayView[String]
