import Combine
import CoreLocation

protocol LocationManager {
  var errorPublisher: AnyPublisher<Error, Never> { get }
  var locationPublisher: AnyPublisher<CLLocation, Never> { get }
}
