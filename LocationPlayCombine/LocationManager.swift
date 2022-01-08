//
//  LocationManager.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import Foundation
import CoreLocation
import Combine

extension Publisher {
  func lastItemsWith(count: Int) -> Publishers.Filter<Publishers.Scan<Self, [Output]>> {
    self.scan([]) {
      return $0.suffix(count - 1) + [$1]
    }.filter{ $0.count == count }
  }
}
enum SimpleAuthorizationStatus {
  case allowed
  case denied
  case unknown
}

extension CLAuthorizationStatus {
  var simplifiedStatus : SimpleAuthorizationStatus {
    switch self {
    case .restricted, .denied:
      return .denied
    case .notDetermined:
      return .unknown
    case .authorizedAlways, .authorizedWhenInUse:
      return .allowed
    @unknown default:
      return .unknown
    }
  }
}

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
enum LocationManagerError : Error {
  case failure(LocationManagerFailureReason)
}
protocol LocationManager {
  func publisherForLocationUpdates() throws -> AnyPublisher<CLLocation,Never>
}

extension CLLocationManager {
  
}
class CoreLocationManager : NSObject, ObservableObject, CLLocationManagerDelegate, LocationManager {
  var managerResult : Result<CLLocationManager,LocationManagerError>
  @Published var authorizationStatus : CLAuthorizationStatus?
  @Published var locationFailure: Error?
  @Published var lastLocations: [CLLocation]?
  @Published var lastLocation: CLLocation?
  var cancellables = [AnyCancellable]()
  
  static func createManager () -> Result<CLLocationManager,LocationManagerError> {
    let manager = CLLocationManager()
    if let reason = LocationManagerFailureReason(basedOnManager: manager) {
      return .failure(.failure( reason))
    } else {
      return .success(manager)
    }
  }
  
  override init() {
    let managerResult = Self.createManager()
    let manager : CLLocationManager?
    if case let .success(pendingAuthorizationManager) = managerResult {
      pendingAuthorizationManager.requestWhenInUseAuthorization()
      manager = pendingAuthorizationManager
    } else {
      manager = nil
    }
    self.managerResult = managerResult
    super.init()
    guard let manager = manager else {
      return
    }
    manager.delegate = self
    
    self.$authorizationStatus.lastItemsWith(count: 2).map{($0[0], $0[1])}.sink(receiveValue: self.onAuthorizationStatusChange(from:to:)).store(in: &self.cancellables)
    
    self.$lastLocations.compactMap{$0}.flatMap{
      $0.publisher
    }.map{$0 as CLLocation?}.assign(to: &self.$lastLocation)
  }
  
  func onAuthorizationStatusChange(from oldStatus: CLAuthorizationStatus?, to newStatus: CLAuthorizationStatus?) {
    let old = oldStatus?.simplifiedStatus ?? .unknown
    let new = newStatus?.simplifiedStatus ?? .unknown
    
    switch (old == new, old, new) {
    case (true, _, _):
      return
    case (false, _, .unknown):
      return
    case (false, _, _):
      self.managerResult = Self.createManager()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.locationFailure = error
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.lastLocations = locations
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.authorizationStatus = manager.authorizationStatus
  }
  
  func publisherForLocationUpdates() throws -> AnyPublisher<CLLocation, Never> {
    return self.$lastLocation.compactMap{$0}
  }
  
  
  
}
