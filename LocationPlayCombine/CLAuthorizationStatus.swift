import CoreLocation

extension CLAuthorizationStatus {
    /// Whether `CLLocationManager` is authorized in any way.
    var isAuthorized: Bool? {
        switch self {
        case .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return nil
        }
    }
}
