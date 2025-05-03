///|
pub fn moonbit_main() -> Unit {
  let args = @sys.get_cli_args()
  guard args is [_, .. args]
  @lib.execute(args)
}

///|
fn main {
  moonbit_main()
}
