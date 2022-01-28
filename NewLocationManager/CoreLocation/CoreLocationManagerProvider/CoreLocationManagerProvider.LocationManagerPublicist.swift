import Combine
import CoreLocation

extension CoreLocationManagerProvider {
  var errorPublisher: AnyPublisher<Error, Never> {
    errorSubject.eraseToAnyPublisher()
  }

  var locationPublisher: AnyPublisher<[CLLocation], Never> {
    locationSubject.eraseToAnyPublisher()
  }
}
