import Combine
import CoreLocation

extension CoreLocationManagerProvider {
  
  public var errorPublisher: AnyPublisher<Error, Never> {
    return self.errorSubject.eraseToAnyPublisher()
  }

  public var locationPublisher: AnyPublisher<[CLLocation], Never> {
    return self.locationSubject.eraseToAnyPublisher()
  }
}
