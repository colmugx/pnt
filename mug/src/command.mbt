///|
pub(open) trait HelpPrinter {
  print_usage(Self) -> Unit
}

///|
pub(open) trait TFlaggable {
  has_flag(Self, TArgs, String) -> Bool
  add_flag(Self, Flag) -> Unit
}

///|
pub(open) trait TCommand: HelpPrinter {
  execute(Self, ArrayView[String]) -> Unit
  name(Self) -> String
  description(Self) -> String
}

///|
pub typealias TArgs = ArrayView[String]
