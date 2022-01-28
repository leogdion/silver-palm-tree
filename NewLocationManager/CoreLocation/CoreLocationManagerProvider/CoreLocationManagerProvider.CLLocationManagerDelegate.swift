import Combine
import CoreLocation

extension CoreLocationManagerProvider {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    observableObjectWillChangePublisher?.send()
    authorizationSubject.send(manager.authorizationStatus)
  }

  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    observableObjectWillChangePublisher?.send()
    locationSubject.send(locations)
  }

  func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    observableObjectWillChangePublisher?.send()
    errorSubject.send(error)
  }
}
