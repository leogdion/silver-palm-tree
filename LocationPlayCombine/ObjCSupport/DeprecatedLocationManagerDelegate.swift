import Combine
import CoreLocation
import Foundation

@objc
public protocol DeprecatedLocationManagerDelegate {
    func deprecatedLocationManager(_ locationManager: DeprecatedLocationManager, didChangeLocationTo location: CLLocation)
    func deprecatedLocationManager(_ locationManager: DeprecatedLocationManager, didFailWith error: Error)
}
