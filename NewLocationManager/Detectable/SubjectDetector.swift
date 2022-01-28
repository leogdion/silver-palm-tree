protocol SubjectDetector {
  func subscriptionWillCancel<Value>(_ subscription: DetectableSubscription<Value>)
  func subscriptionWasReceived<Value>(_ subscription: DetectableSubscription<Value>)
}
