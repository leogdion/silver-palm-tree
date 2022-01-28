import Combine
import CoreLocation
import Foundation

extension DetectableSubject {
  func subscriptionWillCancel<Value>(_ subscription: DetectableSubscription<Value>) {
    tracker!.subscriptionWillCancel(subscription)
    cancellables[subscription.id]!.cancel()
    cancellables.removeValue(forKey: subscription.id)
  }
}
