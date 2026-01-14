///|
pub fn clear_line() -> String {
  "\r\u001b[K"
}

///|
pub fn move_up(n : Int) -> String {
  if n > 0 {
    "\u001b[\{n}A"
  } else {
    ""
  }
}

///|
pub fn show_cursor() -> String {
  "\u001b[?25h"
}

///|
pub fn hide_cursor() -> String {
  "\u001b[?25l"
}

///|
pub fn red(s : String) -> String {
  "\u001b[31m\{s}\u001b[0m"
}

///|
pub fn green(s : String) -> String {
  "\u001b[32m\{s}\u001b[0m"
}

///|
pub fn yellow(s : String) -> String {
  "\u001b[33m\{s}\u001b[0m"
}

///|
pub fn blue(s : String) -> String {
  "\u001b[34m\{s}\u001b[0m"
}

///|
pub fn cyan(s : String) -> String {
  "\u001b[36m\{s}\u001b[0m"
}

///|
pub fn bold(s : String) -> String {
  "\u001b[1m\{s}\u001b[0m"
}

///|
pub fn dim(s : String) -> String {
  "\u001b[2m\{s}\u001b[0m"
}
