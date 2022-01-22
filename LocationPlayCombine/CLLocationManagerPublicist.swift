import Combine
import CoreLocation

/// Implements the publishers needed to manage a `CLLocationManager`.
class CLLocationManagerPublicist: NSObject, CLLocationManagerCombineDelegate {
    let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

    let locationSubject = PassthroughSubject<[CLLocation], Never>()

    let errorSubject = PassthroughSubject<Error, Never>()

    //  Publishes `CLAuthorizationStatus` changes.
    public let authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never>

    /// Publishes `CLLocation` updates.
    public let locationPublisher: AnyPublisher<[CLLocation], Never>

    /// Publishes `Error` as received from the `CLLocationManager`.
    public let errorPublisher: AnyPublisher<Error, Never>

    let manager: CLLocationManager

    /// Gets the error state if any of the `CLLocationManager`.
    public var managerError: LocationManagerError? {
        return manager.error
    }

    /// Create a Publisict which providers publsihers from the `CLLocationManager`
    /// - Parameter manager: the CLLocationManager
    public init(manager: CLLocationManager) {
        self.manager = manager

        // start with `notDeterminded` then just listen the `authorizationSubject`
        authorizationPublisher = Just(.notDetermined)
            .merge(with:
                authorizationSubject).eraseToAnyPublisher()

        locationPublisher = locationSubject.eraseToAnyPublisher()
        errorPublisher = errorSubject.eraseToAnyPublisher()
        super.init()

        // set the delegate
        self.manager.delegate = self
        // start updating location right away
        self.manager.startUpdatingLocation()
    }

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations)
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        errorSubject.send(error)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationSubject.send(manager.authorizationStatus)
    }
}
