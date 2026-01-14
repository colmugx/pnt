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
  mug_print(@ansiutils.clear_line())
  println("✓ \{self.msg} \{msg}")
  mug_print(@ansiutils.show_cursor())
}

///|
extern "C" fn mug_fflush_stdout() -> Unit = "mug_fflush_stdout"

///|
#borrow(str)
pub extern "C" fn mug_print(str : String) -> Unit = "mug_print"

///|
fn flush_stdout() -> Unit {
  mug_fflush_stdout()
}
