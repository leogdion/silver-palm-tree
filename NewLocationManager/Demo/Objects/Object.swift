import Combine
import CoreLocation

class Object: ObservableObject {
  let provider: LocationManagerProvider
  @Published var locations: [LocationData]
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

  init(locations: [LocationData] = .init()) {
    provider = CoreLocationManagerProvider()
    self.locations = locations

    provider.authorizationPublisher.assign(to: &$authorizationStatus)
    provider.observableObjectWillChangePublisher = objectWillChange
  }

  func add(withUpdates shouldUpdate: Bool) {
    let manager = provider.createManager()
    locations.append(.init(manager: manager, location: provider.lastLocation, shouldUpdate: shouldUpdate))
  }

  func remove() {
    _ = locations.popLast()
  }

  func requestAuthorization() {
    provider.requestAuthorization()
  }
}
