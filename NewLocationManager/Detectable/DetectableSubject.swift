import Combine
import CoreLocation
import Foundation

class DetectableSubject<Value>: Subject, SubscriptionDetector {  
  let subject: PassthroughSubject<Value, Never>
  var tracker: SubjectDetector?
  var cancellables = [UUID: AnyCancellable]()

  internal init() {
    subject = PassthroughSubject()
  }

  typealias Output = Value

  typealias Failure = Never
}
