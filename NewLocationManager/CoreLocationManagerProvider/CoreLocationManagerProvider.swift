import Combine
import CoreLocation

class CoreLocationManagerProvider: NSObject, LocationManagerProvider, CLLocationManagerDelegate, Tracker, LocationManagerPublicist {
  let manager: CLLocationManager
  
  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = TrackablePublisher<[CLLocation]>()

  let errorSubject = TrackablePublisher<Error>()
  
  var counter: Int = 0 {
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
  
  var observableObjectWillChangePublisher: ObservableObjectPublisher?
  
  override internal init() {
    let manager = CLLocationManager()
    self.manager = manager

    super.init()

    manager.delegate = self
    locationSubject.tracker = self
    errorSubject.tracker = self
  }
}
