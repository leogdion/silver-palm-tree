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

  func add() {
    let manager = provider.createManager()
    locations.append(.init(manager: manager))
  }

  func remove() {
    _ = locations.popLast()
  }

  func requestAuthorization() {
    provider.requestAuthorization()
  }
}