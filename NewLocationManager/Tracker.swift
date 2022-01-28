protocol Tracker {
  func subscriptionWillCancel<Value>(_ subscription: TrackableSubscription<Value>)
  func subscriptionWasReceived<Value>(_ subscription: TrackableSubscription<Value>)
}
