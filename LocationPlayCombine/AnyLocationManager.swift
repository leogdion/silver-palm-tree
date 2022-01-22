//
//  AnyLocationManager.swift
//
//  Created by Leo Dion on 1/14/22.
//

import Combine
import CoreLocation
import Foundation

/// Location Manager with information from the central `CLLocationManager`.
public protocol AnyLocationManager {
    /// The last location received by the `CLLocationManager`.
    var lastLocation: CLLocation? { get }

    /// The last error received by the `CLLocationManager`.
    var lastError: Error? { get }

    /// The last error state if any of the `CLLocationManager`.
    var managerError: LocationManagerError? { get }

    /// The last `CLAuthorizationStatus` of the `CLLocationManager`.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Publisher listens to changes in `CLLocation`
    var anyLocationPublisher: AnyPublisher<CLLocation, Never> { get }

    /// Publisher listens to `Error` instances as they come in.
    var anyLocationErrorPublisher: AnyPublisher<Error, Never> { get }

    /// Publishes `LocationManagerError` as the authorization changes.
    var anyManagerErrorPublisher: AnyPublisher<LocationManagerError, Never> { get }

    /// Publishes `CLAuthorizationStatus` changes.
    var anyAuthorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
}
