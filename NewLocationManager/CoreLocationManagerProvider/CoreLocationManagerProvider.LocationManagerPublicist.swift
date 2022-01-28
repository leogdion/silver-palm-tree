import Combine
import CoreLocation

public extension CoreLocationManagerProvider {
  var errorPublisher: AnyPublisher<Error, Never> {
    errorSubject.eraseToAnyPublisher()
  }

  var locationPublisher: AnyPublisher<[CLLocation], Never> {
    locationSubject.eraseToAnyPublisher()
  }
}
