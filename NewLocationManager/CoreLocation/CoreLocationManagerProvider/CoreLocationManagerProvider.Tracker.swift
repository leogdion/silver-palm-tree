import Combine
import CoreLocation

extension CoreLocationManagerProvider {
  func subscriptionWasReceived<Value>(_: DetectableSubscription<Value>) {
    counter += 1
  }

  func subscriptionWillCancel<Value>(_: DetectableSubscription<Value>) {
    counter -= 1
  }
}
