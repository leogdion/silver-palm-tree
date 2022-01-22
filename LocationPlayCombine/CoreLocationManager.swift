import Combine
import CoreLocation

class CoreLocationManager: ObservableLocationManager {
    static let shared: AnyLocationManager = CoreLocationManager()

    typealias LocationValuePublisher = Publishers.CompactMap<Published<CLLocation?>.Publisher, CLLocation>
    typealias LocationErrorPublisher = Publishers.CompactMap<Published<Error?>.Publisher, Error>
    typealias ManagerErrorPublisher =  Publishers.CompactMap<Published<LocationManagerError?>.Publisher, LocationManagerError>
    typealias AuthorizationStatusPublisher = Published<CLAuthorizationStatus>.Publisher

    @Published var managerPublicist: CLLocationManagerCombineDelegate
    @Published var managerError: LocationManagerError?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: Error?
    @Published var lastLocation: CLLocation?

    static func createManager() -> CLLocationManagerCombineDelegate {
        let manager = CLLocationManager()
        if manager.authorizationStatus.isAuthorized != true {
            manager.requestWhenInUseAuthorization()
        }
        return CLLocationManagerPublicist(manager: manager)
    }

    init() {
        // create the first manager
        managerPublicist = Self.createManager()

        // get the manager error if there is one
        $managerPublicist.share().map {
            $0.managerError
        }.assign(to: &$managerError)

        // get the authorization status and store it
        $managerPublicist.share().flatMap {
            $0.authorizationPublisher
        }.assign(to: &$authorizationStatus)

        // get the location and store it
        $managerPublicist.share().flatMap {
            $0.locationPublisher
        }.flatMap(Publishers.Sequence.init(sequence:))
            // in order to match the property map to Optional
            .map { $0 as CLLocation? }
            // store the value in the location property
            .assign(to: &$lastLocation)

        $managerPublicist.share().flatMap {
            $0.errorPublisher
        }.map { $0 as Error? }.assign(to: &$lastError)

        // if the authorized status changes, create a new `CLLocationManager`
        $authorizationStatus.compactMap { $0.isAuthorized }.lastItemsWith(count: 2).map { ($0[0], $0[1]) }.compactMap(onAuthorizationStatusChange(from:to:))
            .assign(to: &$managerPublicist)
    }

    /// If the authorization status changes, create a new `CLLocationManagerCombineDelegate`
    /// - Parameters:
    ///   - oldStatus: The old authorized status.
    ///   - newStatus: The new authorized status.
    /// - Returns: a new `CLLocationManagerCombineDelegate` if the status changed.
    func onAuthorizationStatusChange(from oldStatus: Bool,
                                     to newStatus: Bool) -> CLLocationManagerCombineDelegate?
    {
        guard oldStatus != newStatus else {
            return nil
        }

        return Self.createManager()
    }

    var locationPublisher: Publishers.CompactMap<Published<CLLocation?>.Publisher, CLLocation> {
        return $lastLocation.compactMap { $0 }
    }

    var managerErrorPublisher: Publishers.CompactMap<Published<LocationManagerError?>.Publisher, LocationManagerError> {
        return $managerError.compactMap { $0 }
    }

    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher {
        return $authorizationStatus
    }

    var locationErrorPublisher: Publishers.CompactMap<Published<Error?>.Publisher, Error> {
        return $lastError.compactMap { $0 }
    }
}
