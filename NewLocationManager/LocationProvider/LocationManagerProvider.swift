import Combine
import CoreLocation

protocol LocationManagerProvider: AnyObject {
  func createManager() -> LocationManager
  var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }

  var observableObjectWillChangePublisher: ObservableObjectPublisher? { get set }
  func requestAuthorization()

  var lastLocation: CLLocation? { get }
  var lastError: Error? { get }
  var authorizedStatus: CLAuthorizationStatus { get }
}
