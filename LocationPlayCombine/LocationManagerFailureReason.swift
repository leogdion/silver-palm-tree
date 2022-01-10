import CoreLocation

public struct LocationManagerFailureReason : OptionSet {
  public let rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public init?(basedOnManager manager: CLLocationManager) {
    
    let managerType = type(of: manager)
    var rawValue = 0

    if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
      rawValue += Self.authorizationDeniedOrRestricted.rawValue
    }
    
    if !managerType.isMonitoringAvailable(for: CLRegion.self) {
      rawValue += Self.regionMonitoringUnavailable.rawValue
    }
    
    if !managerType.locationServicesEnabled() {
      rawValue += Self.servicesDisabled.rawValue
    }
    
    guard rawValue > 0 else {
      return nil
    }
    
    self.init(rawValue: rawValue)
  }
  
  public static let authorizationDeniedOrRestricted = Self(rawValue: 1)
  public static let regionMonitoringUnavailable = Self(rawValue: 2)
  public static let servicesDisabled = Self(rawValue: 4)
}
