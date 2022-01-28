import Combine
import CoreLocation

class CoreLocationManagerProvider: NSObject, LocationManagerProvider, CLLocationManagerDelegate, Tracker {
  var observableObjectWillChangePublisher: ObservableObjectPublisher?
  @Published var counter: Int = 0 {
    didSet {
      print("\(oldValue) => \(counter)")
      if oldValue == 0, counter > 0 {
        print("starting location updates")
        manager.startUpdatingLocation()
      } else if oldValue > 0, counter == 0 {
        print("stopping location updates")
        manager.stopUpdatingLocation()
      }
    }
  }

  func subscriptionWasReceived<Value>(_: TrackableSubscription<Value>) {
    counter += 1
  }

  func subscriptionWillCancel<Value>(_: TrackableSubscription<Value>) {
    counter -= 1
  }

  func requestAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  override internal init() {
    let manager = CLLocationManager()
    self.manager = manager

    authorizationPublisher = Just(manager.authorizationStatus)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()

    locationPublisher = locationSubject.eraseToAnyPublisher()
    errorPublisher = errorSubject.eraseToAnyPublisher()

    super.init()

    manager.delegate = self
    locationSubject.tracker = self
    errorSubject.tracker = self
  }

  let manager: CLLocationManager

  public let errorPublisher: AnyPublisher<Error, Never>

  public let authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never>

  public let locationPublisher: AnyPublisher<[CLLocation], Never>

  func createManager() -> LocationManager {
    CoreLocationManager(provider: self)
  }

  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = TrackablePublisher<[CLLocation]>()

  let errorSubject = TrackablePublisher<Error>()

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
