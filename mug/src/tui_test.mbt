///|
test "Spinner::new creates spinner with message" {
  let spinner = Spinner::new("Loading...")
  inspect(spinner.msg, content="Loading...")
  inspect(spinner.idx.to_string(), content="0")
}

///|
test "Spinner has correct frame array" {
  let spinner = Spinner::new("Test")
  inspect(spinner.frames.length().to_string(), content="10")
  inspect(spinner.frames[0], content="⠋")
  inspect(spinner.frames[1], content="⠙")
}

///|
test "Spinner::tick advances frame index" {
  let spinner = Spinner::new("Working")

  // Initial state
  inspect(spinner.idx.to_string(), content="0")

  // First tick
  spinner.tick()
  inspect(spinner.idx.to_string(), content="1")

  // Second tick
  spinner.tick()
  inspect(spinner.idx.to_string(), content="2")

  // Continue to end of frames
  for i = 0; i < 7; i = i + 1 {
    spinner.tick()
  }
  inspect(spinner.idx.to_string(), content="9")

  // Should wrap around
  spinner.tick()
  inspect(spinner.idx.to_string(), content="0")
}

///|
test "Spinner wraps around frames correctly" {
  let spinner = Spinner::new("Test")

  // Advance through all frames
  for i = 0; i < 10; i = i + 1 {
    spinner.tick()
  }

  // Should be back to 0
  inspect(spinner.idx.to_string(), content="0")

  // One more tick
  spinner.tick()
  inspect(spinner.idx.to_string(), content="1")
}

///|
test "Spinner frame sequence is consistent" {
  let spinner1 = Spinner::new("A")
  let spinner2 = Spinner::new("B")

  // Both should have same initial state
  inspect(spinner1.idx.to_string(), content="0")
  inspect(spinner2.idx.to_string(), content="0")

  // Tick both same number of times
  spinner1.tick()
  spinner1.tick()
  spinner2.tick()
  spinner2.tick()

  // Should have same index
  inspect(spinner1.idx.to_string(), content="2")
  inspect(spinner2.idx.to_string(), content="2")
}
