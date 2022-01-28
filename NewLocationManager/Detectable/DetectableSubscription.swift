import Combine
import Foundation

class DetectableSubscription<Value>: Subscription {
  let id: UUID
  internal init(publisher: SubscriptionDetector) {
    id = UUID()
    self.publisher = publisher
  }

  var publisher: SubscriptionDetector?

  func request(_: Subscribers.Demand) {}

  func cancel() {
    publisher?.subscriptionWillCancel(self)
    publisher = nil
  }
}
