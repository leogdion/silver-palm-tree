import Combine
import CoreLocation

class CoreLocationManagerProvider: NSObject, LocationManagerProvider, CLLocationManagerDelegate, SubjectDetector, LocationManagerPublicist {
  var cancellables = [AnyCancellable]()
  let manager: CLLocationManager
  
  let authorizationSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(CLAuthorizationStatus.notDetermined)
  let locationSubject = DetectableSubject<[CLLocation]>()
  let errorSubject = DetectableSubject<Error>()
  
  var lastLocation : CLLocation?
  var lastError : Error?
  
  var observableObjectWillChangePublisher: ObservableObjectPublisher?
  
  static let minimumCounterForLocationUpdates = 3

  var counter: Int = 0 {
    didSet {
      let didStartLocationUpdates = oldValue >= Self.minimumCounterForLocationUpdates
      let shouldStartLocationUpdates = self.counter >= Self.minimumCounterForLocationUpdates
      
      guard didStartLocationUpdates != shouldStartLocationUpdates else {
        return
      }
      
      if shouldStartLocationUpdates {
        print("starting location updates")
        self.manager.startUpdatingLocation()
      } else {
        print("stopping location updates")
        self.manager.stopUpdatingLocation()
      }
    }
  }

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
