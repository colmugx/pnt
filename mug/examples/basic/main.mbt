///|
/// Basic CLI application using Mug framework
/// This example demonstrates a simple CLI with custom commands

pub fn main {
  // Create a new CLI application
  let app = @app.App::new("basic", "A basic CLI example")

  // Set version
  app.version("1.0.0")

  // Add custom commands
  let greet = GreetCommand::{}
  app.add_command(greet)

  let calc = CalcCommand::{}
  app.add_command(calc)

  // Execute the application with command-line arguments
  let args = @sys.argv.get_view()
  app.execute(args)
}

///|
/// Greet command - says hello to the user
pub struct GreetCommand {}

impl TCommand for GreetCommand with name(_) {
  "greet"
}

impl TCommand for GreetCommand with description(_) {
  "Greet someone by name"
}

impl TCommand for GreetCommand with execute(self, args) {
  if args.length() > 0 {
    println("Hello, \{args[0]}!")
  } else {
    println("Hello, World!")
  }
}

impl HelpPrinter for GreetCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
  println("    Usage: basic greet [name]")
}

///|
/// Calc command - performs basic calculations
pub struct CalcCommand {}

impl TCommand for CalcCommand with name(_) {
  "calc"
}

impl TCommand for CalcCommand with description(_) {
  "Perform basic calculations"
}

impl TCommand for CalcCommand with execute(self, args) {
  if args.length() < 3 {
    println("Error: Missing arguments")
    println("Usage: basic calc <number1> <operator> <number2>")
    println("Example: basic calc 5 + 3")
    return
  }

  let n1 = parse_int(args[0])
  let op = args[1]
  let n2 = parse_int(args[2])

  let result = match op {
    "+" => n1 + n2
    "-" => n1 - n2
    "*" => n1 * n2
    "/" => {
      if n2 == 0 {
        println("Error: Division by zero")
        return
      }
      n1 / n2
    }
    _ => {
      println("Error: Unknown operator '\{op}'")
      return
    }
  }

  println("Result: \{result}")
}

impl HelpPrinter for CalcCommand with print_usage(self) {
  println("  \{self.name()} - \{self.description()}")
  println("    Usage: basic calc <num1> <operator> <num2>")
  println("    Operators: +, -, *, /")
}

///|
/// Parse string to integer (simple implementation)
fn parse_int(s : String) -> Int {
  // This is a simplified implementation
  // In production, you'd want proper error handling
  let mut result = 0
  let mut i = 0
  let digits = "0123456789"
  let mut negative = false

  if s.length() > 0 && s[0] == '-' {
    negative = true
    i = 1
  }

  while i < s.length() {
    let c = s[i]
    let digit_idx = digits.index_of(c)
    match digit_idx {
      Some(idx) => {
        result = result * 10 + idx
      }
      None => {
        // Invalid character, just return 0
        return 0
      }
    }
    i = i + 1
  }

  if negative {
    -result
  } else {
    result
  }
}

///|
/// Find index of character in string
fn String::index_of(self : String, c : Char) -> Int? {
  let mut i = 0
  while i < self.length() {
    if self[i] == c {
      return Some(i)
    }
    i = i + 1
  }
  None
}
