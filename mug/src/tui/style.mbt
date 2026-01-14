///|
pub enum ProgressStyle {
  ASCII // [===>   ]
  Block // [████░░░]
  Custom(String, String, String) // bar, bg, head
}

///|
fn ProgressStyle::get_chars(self : ProgressStyle) -> (String, String, String) {
  match self {
    ASCII => ("=", " ", ">")
    Block => ("█", "░", "█")
    Custom(bar, bg, head) => (bar, bg, head)
  }
}
