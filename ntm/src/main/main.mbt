///|
fn main {
  let args = @sys.get_cli_args()
  guard args is [app, .. rest]
  @internal.execute(app, rest)
}
