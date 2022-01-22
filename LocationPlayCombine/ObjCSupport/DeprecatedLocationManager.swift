import Combine
import CoreLocation
import Foundation

@objc
public protocol DeprecatedLocationManager {
    var isAvailable: Bool { get }
    weak var delegate: DeprecatedLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
}
