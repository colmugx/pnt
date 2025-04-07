///|
fn main {
  let args = @sys.get_cli_args()
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }

  if url == "" {
    let tips =
      #| No request url.
      #|
      #| Usage:
      #| ntm <url>
    println(tips)
    return
  }

  println("It Works! You've requested: \{url}")
  println(@request.get(url))
}

///|
test "main/no_args" {
  let args_ = @sys.get_cli_args()
  inspect!(args_.length(), content="0")
}

///|
test "main/empty_url" {
  let args = ["ntm1"]
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }
  inspect!(url, content="")
}

///|
test "main/with_url" {
  let args = ["ntm1", "https://example.com"]
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }
  inspect!(url, content="https://example.com")
}
