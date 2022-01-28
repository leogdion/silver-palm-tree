import Combine
import CoreLocation

protocol LocationManagerPublicist {
  var errorPublisher: AnyPublisher<Error, Never> { get }
  var locationPublisher: AnyPublisher<[CLLocation], Never> { get }
}
