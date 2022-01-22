//
//  LocationManager.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import Combine
import CoreLocation
import Foundation

public protocol LocationManager: AnyLocationManager  {
    associatedtype LocationValuePublisher: Publisher where LocationValuePublisher.Output == CLLocation, LocationValuePublisher.Failure == Never
    associatedtype LocationErrorPublisher: Publisher where LocationErrorPublisher.Output == Error, LocationErrorPublisher.Failure == Never
    associatedtype ManagerErrorPublisher: Publisher where ManagerErrorPublisher.Output == LocationManagerError, ManagerErrorPublisher.Failure == Never
    associatedtype AuthorizationStatusPublisher: Publisher where AuthorizationStatusPublisher.Output == CLAuthorizationStatus, AuthorizationStatusPublisher.Failure == Never

    /// Publisher listens to changes in `CLLocation`
    var locationPublisher: LocationValuePublisher { get }

    /// Publisher listens to `Error` instances as they come in.
    var locationErrorPublisher: LocationErrorPublisher { get }

    /// Publishes `LocationManagerError` as the authorization changes.
    var managerErrorPublisher: ManagerErrorPublisher { get }

    /// Publishes `CLAuthorizationStatus` changes.
    var authorizationStatusPublisher: AuthorizationStatusPublisher { get }
}

public extension LocationManager {
    var anyLocationPublisher: AnyPublisher<CLLocation, Never> {
        locationPublisher.eraseToAnyPublisher()
    }

    var anyLocationErrorPublisher: AnyPublisher<Error, Never> {
        locationErrorPublisher.eraseToAnyPublisher()
    }

    var anyManagerErrorPublisher: AnyPublisher<LocationManagerError, Never> {
        managerErrorPublisher.eraseToAnyPublisher()
    }

    var anyAuthorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusPublisher.eraseToAnyPublisher()
    }
}

public extension Publishers {
    /// Shared publisher of location information.
    static var location: AnyLocationManager {
        return CoreLocationManager.shared
    }
}
