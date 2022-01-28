protocol SubscriptionDetector {
  func subscriptionWillCancel<Value>(_ subscription: DetectableSubscription<Value>)
}
