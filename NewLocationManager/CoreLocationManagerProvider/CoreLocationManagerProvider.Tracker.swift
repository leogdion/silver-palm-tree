import Combine
import CoreLocation

extension CoreLocationManagerProvider {

  func subscriptionWasReceived<Value>(_: TrackableSubscription<Value>) {
    counter += 1
  }

  func subscriptionWillCancel<Value>(_: TrackableSubscription<Value>) {
    counter -= 1
  }
}
