//
//  LocationManager.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import Foundation
import CoreLocation
import Combine

public protocol CLLocationManagerCombineDelegate: CLLocationManagerDelegate {
  var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
  var locationPublisher: AnyPublisher<[CLLocation], Never> { get }
  // func headingPublisher() -> AnyPublisher<CLHeading?, Never>
  // func errorPublisher() -> AnyPublisher<Error?, Never>
}

public class CLLocationManagerPublicist: NSObject, CLLocationManagerCombineDelegate {
  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = PassthroughSubject<[CLLocation], Never>()
  
  let errorSubject = PassthroughSubject<Error, Never>()

  public let authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never>

  public let locationPublisher: AnyPublisher<[CLLocation], Never>
  
  public let errorPublisher: AnyPublisher<Error, Never>
  
  public let manager : CLLocationManager

  public init(manager : CLLocationManager) {
    self.manager = manager
    
    authorizationPublisher = Just(.notDetermined)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()

    locationPublisher = locationSubject.eraseToAnyPublisher()
    errorPublisher = errorSubject.eraseToAnyPublisher()
    super.init()
    
    self.manager.delegate = self
    self.manager.startUpdatingLocation()
  }

  public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationSubject.send(locations)
  }

  public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    self.errorSubject.send(error)
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationSubject.send(manager.authorizationStatus)
  }
}

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



class CoreLocationManager : ObservableObject, LocationManager {
  var managerResult : Result<CLLocationManagerCombineDelegate,LocationManagerError>
  @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  @Published var locationFailure: Error?
  @Published var lastLocation: CLLocation?
  
  var cancellables = [AnyCancellable]()
  
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
    
    let authPub = publicist.authorizationPublisher.share()
    authPub.assign(to: &$authorizationStatus)
    authPub.lastItemsWith(count: 2).map{($0[0], $0[1])}.sink(receiveValue: self.onAuthorizationStatusChange(from:to:)).store(in: &self.cancellables)
    
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
//
//  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//    self.locationFailure = error
//  }
//
//  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    self.lastLocations = locations
//  }
//
//  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//    self.authorizationStatus = manager.authorizationStatus
//  }
  
  func publisherForLocationUpdates() throws -> AnyPublisher<CLLocation, Never> {
    return self.$lastLocation.compactMap{$0}.eraseToAnyPublisher()
  }
  
  
  
}
