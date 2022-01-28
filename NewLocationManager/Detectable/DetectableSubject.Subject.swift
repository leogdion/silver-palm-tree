import Combine
import CoreLocation
import Foundation

extension DetectableSubject {
  func send(completion: Subscribers.Completion<Never>) {
    self.subject.send(completion: completion)
  }
  
  func send(subscription: Subscription) {
    self.subject.send(subscription: subscription)
  }
  
  func send(_ input: Value) {
    subject.send(input)
  }

  func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Value == S.Input {
    let subscription = DetectableSubscription<Value>(publisher: self)

    subscriber.receive(subscription: subscription)
    let cancellable =
      subject.sink { value in
        subscription.request(subscriber.receive(value))
      }
    cancellables[subscription.id] = cancellable
    tracker?.subscriptionWasReceived(subscription)
  }
}
