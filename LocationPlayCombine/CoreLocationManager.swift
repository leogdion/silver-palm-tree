import Combine
import CoreLocation

class CoreLocationManager : ObservableLocationManager {
  
  typealias LocationValuePublisher = Publishers.CompactMap<Published<CLLocation?>.Publisher, CLLocation>
  
  typealias LocationErrorPublisher = Publishers.CompactMap<Published<Error?>.Publisher, Error>
  
  typealias ManagerErrorPublisher =  Publishers.CompactMap<Published<LocationManagerError?>.Publisher, LocationManagerError>

  
  typealias AuthorizationStatusPublisher = Published<CLAuthorizationStatus>.Publisher
  

  
  @Published var managerResult : Result<CLLocationManagerCombineDelegate,LocationManagerError>
  @Published var managerError : LocationManagerError?
  @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  @Published var lastError: Error?
  @Published var lastLocation: CLLocation?
    
  static func createManager () -> Result<CLLocationManagerCombineDelegate,LocationManagerError> {
    let manager = CLLocationManager()
    if let reason = LocationManagerFailureReason(basedOnManager: manager) {
      return .failure(.failure( reason))
    } else {
      manager.requestWhenInUseAuthorization()
      return .success(CLLocationManagerPublicist(manager: manager))
    }
  }
  
  init() {
    let managerResult = Self.createManager()
    self.managerResult = managerResult
    guard let publicist = try? managerResult.get() else {
      return
    }
    
    publicist.authorizationPublisher.assign(to: &$authorizationStatus)
    
    $authorizationStatus.lastItemsWith(count: 2).map{($0[0], $0[1])}.compactMap(self.onAuthorizationStatusChange(from:to:)).assign(to: &self.$managerResult)
    
    publicist.locationPublisher
          // convert the array of CLLocation into a Publisher itself
          .flatMap(Publishers.Sequence.init(sequence:))
          // in order to match the property map to Optional
          .map { $0 as CLLocation? }
          // since this is used in the UI,
          //  it needs to be on the main DispatchQueue
          .receive(on: DispatchQueue.main)
          // store the value in the location property
          .assign(to: &$lastLocation)
    
    $managerResult.compactMap{
      guard case let .failure(error) = $0 else {
        return nil
      }
      return error
    }.assign(to: &self.$managerError)
  }
  
  func onAuthorizationStatusChange(from oldStatus: CLAuthorizationStatus?, to newStatus: CLAuthorizationStatus?) -> Result<CLLocationManagerCombineDelegate, LocationManagerError>? {
    let old = oldStatus?.simplifiedStatus ?? .unknown
    let new = newStatus?.simplifiedStatus ?? .unknown
    
    guard old != new || old == .unknown || new == .unknown else {
      return nil
    }

    return Self.createManager()
    
  }
  
  var locationPublisher: Publishers.CompactMap<Published<CLLocation?>.Publisher, CLLocation> {
    return self.$lastLocation.compactMap{$0}
  }
  
  var managerErrorPublisher: Publishers.CompactMap<Published<LocationManagerError?>.Publisher, LocationManagerError> {
    return self.$managerError.compactMap{$0}
  }
  
  var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher {
    return self.$authorizationStatus
  }
  
  var lcationErrorPublisher: Publishers.CompactMap<Published<Error?>.Publisher, Error> {
    return self.$lastError.compactMap{$0}
  }
  
//  func publisherForLocationUpdates() throws -> Publishers.CompactMap<Published<CLLocation?>.Publisher, CLLocation> {
//    return self.$lastLocation.compactMap{$0}
//  }
  
  
  
}
