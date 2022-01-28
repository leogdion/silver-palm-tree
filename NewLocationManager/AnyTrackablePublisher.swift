protocol AnyTrackablePublisher {
  func subscriptionWillCancel<Value>(_ subscription: TrackableSubscription<Value>)
}
