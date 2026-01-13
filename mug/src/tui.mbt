///|
pub fn clear_line() -> Unit {
  println("\r\u001b[K")
}

///|
pub fn move_up(n : Int) -> Unit {
  if n > 0 {
    println("\u001b[\{n}A")
  }
}

///|
pub fn show_cursor() -> Unit {
  println("\u001b[?25h")
}

///|
pub fn hide_cursor() -> Unit {
  println("\u001b[?25l")
}

///|
pub(all) struct Spinner {
  frames : Array[String]
  msg : String
  mut idx : Int
}

///|
pub fn Spinner::new(msg : String) -> Spinner {
  {
    frames: [
      "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏",
    ],
    msg,
    idx: 0,
  }
}

///|
pub fn Spinner::tick(self : Spinner) -> Unit {
  let frame = self.frames[self.idx]
  self.idx = (self.idx + 1) % self.frames.length()
  println("\r\{frame} \{self.msg}")
  flush_stdout()
}

///|
pub fn Spinner::finish(self : Spinner, msg : String) -> Unit {
  clear_line()
  println("✓ \{self.msg} \{msg}")
  show_cursor()
}

///|
/// Flush standard output - required for proper Spinner animations
/// FFI implementation provided in stub.c for native targets
/// For wasm/js targets, this is a no-op as buffering is handled by the runtime
extern "C" fn mug_fflush_stdout() -> Unit = "mug_fflush_stdout"

///|
fn flush_stdout() -> Unit {
  mug_fflush_stdout()
}
