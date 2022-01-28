import Combine
import CoreLocation
import Foundation

class TrackablePublisher<Value>: Publisher, AnyTrackablePublisher {
  var tracker: Tracker?

  var cancellables = [UUID: AnyCancellable]()

  internal init() {
    subject = PassthroughSubject()
  }

  func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Value == S.Input {
    let subscription = TrackableSubscription<Value>(publisher: self)

    subscriber.receive(subscription: subscription)
    let cancellable =
      subject.sink { value in
        subscription.request(subscriber.receive(value))
      }
    cancellables[subscription.id] = cancellable
    tracker?.subscriptionWasReceived(subscription)
  }

  func subscriptionWillCancel<Value>(_ subscription: TrackableSubscription<Value>) {
    tracker!.subscriptionWillCancel(subscription)
    cancellables[subscription.id]!.cancel()
    cancellables.removeValue(forKey: subscription.id)
  }

  func send(_ input: Value) {
    subject.send(input)
  }

  typealias Output = Value

  typealias Failure = Never

  let subject: PassthroughSubject<Value, Never>
}
