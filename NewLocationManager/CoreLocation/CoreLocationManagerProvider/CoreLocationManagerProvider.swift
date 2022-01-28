import Combine
import CoreLocation

class CoreLocationManagerProvider: NSObject, LocationManagerProvider, CLLocationManagerDelegate, SubjectDetector, LocationManagerPublicist {
  
  var cancellables = [AnyCancellable]()
  var lastLocation : CLLocation?
  var lastError : Error?
  
  let manager: CLLocationManager

  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = DetectableSubject<[CLLocation]>()

  let errorSubject = DetectableSubject<Error>()

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
    
    locationSubject.map{$0.last}.assign(to: \.lastLocation, on: self).store(in: &self.cancellables)
    errorSubject.map{$0 as Error?}.assign(to: \.lastError, on: self).store(in: &self.cancellables)
  }
}
