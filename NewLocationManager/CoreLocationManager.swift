import Combine
import CoreLocation

class CoreLocationManager: LocationManager {
  let provider: LocationManagerPublicist

  internal init(provider: LocationManagerPublicist) {
    self.provider = provider
  }

  var errorPublisher: AnyPublisher<Error, Never> {
    provider.errorPublisher
  }

  var locationPublisher: AnyPublisher<CLLocation, Never> {
    provider.locationPublisher.flatMap(
      Publishers.Sequence.init
    ).eraseToAnyPublisher()
  }
}
