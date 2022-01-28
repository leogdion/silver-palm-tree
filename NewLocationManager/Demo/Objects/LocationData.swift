import Combine
import CoreLocation
import Foundation

class LocationData: Identifiable, ObservableObject {
  let id: UUID
  let manager: LocationManager
  @Published var location: CLLocation?
  @Published var error: Error?

  internal init(manager: LocationManager, id: UUID = .init(), location: CLLocation? = nil, error: Error? = nil, shouldUpdate: Bool = true) {
    self.id = id
    self.manager = manager
    self.location = location
    self.error = error

    if shouldUpdate {
      manager.errorPublisher.map { $0 as Error? }.receive(on: DispatchQueue.main).assign(to: &$error)
      manager.locationPublisher.map { $0 as CLLocation? }.receive(on: DispatchQueue.main).assign(to: &$location)
    }
  }
}
