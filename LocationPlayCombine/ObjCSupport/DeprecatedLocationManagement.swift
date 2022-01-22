import CoreLocation
import Foundation

@objc
public class DeprecatedLocationManagement: NSObject {
    override fileprivate init() {
        super.init()
    }

    @objc
    public static func createManager() -> DeprecatedLocationManager {
        return DeprecatedCoreLocationManager()
    }
}
