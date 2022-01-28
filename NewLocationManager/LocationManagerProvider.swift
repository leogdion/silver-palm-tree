import Combine
import CoreLocation

protocol LocationManagerProvider {
  func createManager() -> LocationManager
  var errorPublisher: AnyPublisher<Error, Never> { get }
  var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
  var locationPublisher: AnyPublisher<[CLLocation], Never> { get }
}
