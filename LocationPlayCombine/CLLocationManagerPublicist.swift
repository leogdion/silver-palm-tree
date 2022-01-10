import Combine
import CoreLocation

public class CLLocationManagerPublicist: NSObject, CLLocationManagerCombineDelegate {
  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = PassthroughSubject<[CLLocation], Never>()
  
  let errorSubject = PassthroughSubject<Error, Never>()

  public let authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never>

  public let locationPublisher: AnyPublisher<[CLLocation], Never>
  
  public let errorPublisher: AnyPublisher<Error, Never>
  
  public let manager : CLLocationManager

  public init(manager : CLLocationManager) {
    self.manager = manager
    
    authorizationPublisher = Just(.notDetermined)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()

    locationPublisher = locationSubject.eraseToAnyPublisher()
    errorPublisher = errorSubject.eraseToAnyPublisher()
    super.init()
    
    self.manager.delegate = self
    self.manager.startUpdatingLocation()
  }

  public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationSubject.send(locations)
  }

  public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    self.errorSubject.send(error)
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationSubject.send(manager.authorizationStatus)
  }
}
