import Combine
import Foundation

class TrackableSubscription<Value>: Subscription {
  let id: UUID
  internal init(publisher: AnyTrackablePublisher) {
    id = UUID()
    self.publisher = publisher
  }

  var publisher: AnyTrackablePublisher?

  func request(_: Subscribers.Demand) {}

  func cancel() {
    publisher?.subscriptionWillCancel(self)
    publisher = nil
  }
}
