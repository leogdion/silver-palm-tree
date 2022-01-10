import Combine
import CoreLocation

public protocol CLLocationManagerCombineDelegate: CLLocationManagerDelegate {
  var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
  var locationPublisher: AnyPublisher<[CLLocation], Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
}
