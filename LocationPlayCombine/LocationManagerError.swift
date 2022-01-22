import CoreLocation

/// A specific error based on the state the device and `CLLocationManager`
public struct LocationManagerError: Error {
    /// Reason for the error.
    let reason: Reason

    fileprivate init(reason: Reason) {
        self.reason = reason
    }

    internal init?(reasonRawValue: Reason.RawValue) {
        guard reasonRawValue > 0 else {
            return nil
        }

        self.init(reason: .init(rawValue: reasonRawValue))
    }

    /// The various reasons location is not avaialble on the device and app.`
    public struct Reason: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            precondition(rawValue > 0)
            self.rawValue = rawValue
        }

        /// `CLLocationManager` does have access in the app.
        public static let authorizationDeniedOrRestricted = Self(rawValue: 1)

        /// Region monitoring is not available on the device.
        public static let regionMonitoringUnavailable = Self(rawValue: 2)

        /// Location services are not available.
        public static let servicesDisabled = Self(rawValue: 4)
    }
}

public extension CLLocationManager {
    /// The error state of the `CLLocationManager` and location services in general.
    var error: LocationManagerError? {
        let managerType = type(of: self)
        var rawValue = 0

        // Check whether `CLLocationManager` does have access in the app.
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            rawValue += LocationManagerError.Reason.authorizationDeniedOrRestricted.rawValue
        }

        // Check whether region monitoring is available on the device.
        if !managerType.isMonitoringAvailable(for: CLRegion.self) {
            rawValue += LocationManagerError.Reason.regionMonitoringUnavailable.rawValue
        }

        // Check whether location services are available.
        if !managerType.locationServicesEnabled() {
            rawValue += LocationManagerError.Reason.servicesDisabled.rawValue
        }

        return .init(reasonRawValue: rawValue)
    }
}
