import CoreLocation

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
