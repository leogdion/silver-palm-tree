import Combine
import CoreLocation
import Foundation

class LocationData: Identifiable, ObservableObject {
//  static func forPreview(withLocation location: CLLocation) -> LocationData {
//    return .init(manager: MockLocationManager(), location: location)
//  }
  internal init(manager: LocationManager, id: UUID = .init(), location: CLLocation? = nil, error: Error? = nil) {
    self.id = id
    self.manager = manager
    self.location = location
    // self.authorizationStatus = authorizationStatus
    self.error = error

    manager.errorPublisher.map { $0 as Error? }.receive(on: DispatchQueue.main).assign(to: &$error)
    // manager.authorizationPublisher.assign(to: &self.$authorizationStatus)
    manager.locationPublisher.map { $0 as CLLocation? }.print().receive(on: DispatchQueue.main).assign(to: &$location)
  }

  let id: UUID
  let manager: LocationManager
  // @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  @Published var location: CLLocation?
  @Published var error: Error?
}
