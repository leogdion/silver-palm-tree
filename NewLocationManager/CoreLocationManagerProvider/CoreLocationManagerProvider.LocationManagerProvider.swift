import Combine
import CoreLocation

extension CoreLocationManagerProvider {  
  public var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
    Just(manager.authorizationStatus)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()
  }

  func requestAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  
  func createManager() -> LocationManager {
    CoreLocationManager(provider: self)
  }
}
