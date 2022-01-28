import Combine
import CoreLocation

class Object: ObservableObject {
  let provider: CoreLocationManagerProvider
  @Published var locations: [LocationData]
  @Published var counter: Int = 0
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

  init(locations: [LocationData] = .init()) {
    provider = CoreLocationManagerProvider()
    self.locations = locations

    provider.authorizationPublisher.assign(to: &$authorizationStatus)
    provider.$counter.assign(to: &$counter)
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
