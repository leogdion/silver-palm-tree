import Combine
import CoreLocation

/// Implements the publishers needed to manage a `CLLocationManager`.
protocol CLLocationManagerCombineDelegate: CLLocationManagerDelegate {
    //  Publishes `CLAuthorizationStatus` changes.
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }

    /// Publishes `CLLocation` updates.
    var locationPublisher: AnyPublisher<[CLLocation], Never> { get }

    /// Publishes `Error` as received from the `CLLocationManager`.
    var errorPublisher: AnyPublisher<Error, Never> { get }

    /// Gets the error state if any of the `CLLocationManager`.
    var managerError: LocationManagerError? { get }
}
