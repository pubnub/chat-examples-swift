import PlaygroundSupport

public func startIndefiniteExecution() {
  // Keep execution going even after reaching EOF
  PlaygroundPage.current.needsIndefiniteExecution = true
}

public func finishExecution() {
  // Playground will terminate after 30s if this isn't called
  PlaygroundPage.current.finishExecution()
}
