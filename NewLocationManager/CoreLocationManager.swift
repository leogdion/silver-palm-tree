import Combine
import CoreLocation

class CoreLocationManager: LocationManager {
  var errorPublisher: AnyPublisher<Error, Never> {
    provider.errorPublisher
  }

  var locationPublisher: AnyPublisher<CLLocation, Never> {
    provider.locationPublisher.flatMap(
      Publishers.Sequence.init
    ).eraseToAnyPublisher()
  }

  internal init(provider: CoreLocationManagerProvider) {
    self.provider = provider
  }

  let provider: CoreLocationManagerProvider
}