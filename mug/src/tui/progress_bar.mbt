///|
pub struct ProgressBar {
  msg : String
  mut total : UInt64
  mut current : UInt64
  width : Int
  // style chars
  mut style : ProgressStyle
  mut bar_char : String
  mut bg_char : String
  mut head_char : String
  // spinner state
  spinner_frames : Array[String]
  mut spinner_idx : Int
  // time state
  start_time : UInt64
  mut last_render_time : UInt64
}

///|
extern "C" fn mug_get_time_ms() -> UInt64 = "mug_get_time_ms"

///|
pub fn ProgressBar::new(msg : String, total : UInt64) -> ProgressBar {
  let style = ProgressStyle::Block
  let (bar, bg, head) = style.get_chars()
  {
    msg,
    total,
    current: 0,
    width: 30,
    start_time: mug_get_time_ms(),
    last_render_time: 0,
    style,
    bar_char: bar,
    bg_char: bg,
    head_char: head,
    spinner_frames: [
      "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏",
    ],
    spinner_idx: 0,
  }
}

///|
pub fn ProgressBar::set_style(
  self : ProgressBar,
  style : ProgressStyle,
) -> Unit {
  self.style = style
  let (bar, bg, head) = style.get_chars()
  self.bar_char = bar
  self.bg_char = bg
  self.head_char = head
}

///|
pub fn ProgressBar::set_total(self : ProgressBar, total : UInt64) -> Unit {
  self.total = total
}

///|
pub fn ProgressBar::set_position(self : ProgressBar, current : UInt64) -> Unit {
  self.current = current
  self.render()
}

///|
pub fn ProgressBar::inc(self : ProgressBar, delta : UInt64) -> Unit {
  self.current += delta
  self.render()
}

///|
pub fn ProgressBar::finish(self : ProgressBar) -> Unit {
  self.finish_with_message("Done")
}

///|
pub fn ProgressBar::finish_with_message(
  self : ProgressBar,
  msg : String,
) -> Unit {
  mug_print(@ansiutils.clear_line())
  let check = @ansiutils.green("✓")
  println("\{check} \{self.msg} \{msg}")
  mug_print(@ansiutils.show_cursor())
}

///|
fn format_bytes(bytes : UInt64) -> String {
  let units = ["B", "KiB", "MiB", "GiB", "TiB"]
  let mut v = bytes.to_double()
  let mut i = 0
  while i < units.length() - 1 && v >= 1024.0 {
    v = v / 1024.0
    i = i + 1
  }
  let s = (v * 100.0).floor() / 100.0
  "\{s} \{units[i]}"
}

///|
fn format_duration(seconds : UInt64) -> String {
  if seconds < 60 {
    "\{seconds}s"
  } else if seconds < 3600 {
    let m = seconds / 60
    let s = seconds % 60
    "\{m}m \{s}s"
  } else {
    let h = seconds / 3600
    let m = seconds % 3600 / 60
    "\{h}h \{m}m"
  }
}

///|
fn ProgressBar::render(self : ProgressBar) -> Unit {
  let now = mug_get_time_ms()
  // Spinner update
  self.spinner_idx = (self.spinner_idx + 1) % self.spinner_frames.length()
  let spinner = self.spinner_frames[self.spinner_idx]

  // Progress calc
  let percent = if self.total > 0 {
    self.current.to_double() / self.total.to_double()
  } else {
    0.0
  }

  // Bar rendering
  let filled_width = (percent * self.width.to_double()).to_int()
  let empty_width = self.width - filled_width
  let mut bar = "["
  for i = 0; i < filled_width; i = i + 1 {
    bar += self.bar_char
  }
  if empty_width > 0 && filled_width < self.width {
    bar += self.head_char
  }
  let padding_len = if filled_width < self.width { empty_width - 1 } else { 0 }
  for i = 0; i < padding_len; i = i + 1 {
    bar += self.bg_char
  }
  bar += "]"

  // Stats
  let current_str = format_bytes(self.current)
  let total_str = format_bytes(self.total)
  let percent_str = (percent * 100.0).to_int().to_string() + "%"

  // Speed & ETA
  let elapsed_ms = now - self.start_time
  let speed_str = if elapsed_ms > 0 {
    let bytes_per_sec = self.current * 1000 / elapsed_ms
    "\{format_bytes(bytes_per_sec)}/s"
  } else {
    "0 B/s"
  }
  let eta_str = if self.current > 0 && self.total > self.current {
    let remaining_bytes = self.total - self.current
    let bytes_per_ms = self.current.to_double() / elapsed_ms.to_double()
    if bytes_per_ms > 0.0 {
      let eta_ms = remaining_bytes.to_double() / bytes_per_ms
      format_duration(eta_ms.to_uint64() / 1000)
    } else {
      "?"
    }
  } else {
    "0s"
  }

  // Ensure we clear line properly
  mug_print(@ansiutils.clear_line())
  mug_print(
    "\r\{@ansiutils.cyan(spinner)} \{self.msg} \{bar} \{current_str}/\{total_str} (\{speed_str}, \{eta_str})",
  )
  flush_stdout()
  self.last_render_time = now
}
