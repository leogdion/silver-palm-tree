import Combine
import CoreLocation
import Foundation

@objc
class DeprecatedCoreLocationManager: NSObject, DeprecatedLocationManager {
    var cancellables = [AnyCancellable]()
    @objc public var distanceFilter: CLLocationDistance = kCLDistanceFilterNone
    let wrapper: AnyLocationManager

    @objc public var isAvailable: Bool {
        return wrapper.managerError == nil
    }

    @objc public weak var delegate: DeprecatedLocationManagerDelegate? {
        didSet {
            guard let delegate = delegate else {
                return
            }

            if let lastLocation = wrapper.lastLocation {
                delegate.deprecatedLocationManager(self, didChangeLocationTo: lastLocation)
            }
        }
    }

    public func onReceiveError(_ error: Error) {
        delegate?.deprecatedLocationManager(self, didFailWith: error)
    }

    public func onReceiveLocation(_ location: CLLocation) {
        delegate?.deprecatedLocationManager(self, didChangeLocationTo: location)
    }

    override public init() {
        wrapper = Publishers.location
        super.init()
        wrapper.anyManagerErrorPublisher.sink(receiveValue: onReceiveError(_:)).store(in: &cancellables)
        wrapper.anyLocationErrorPublisher.sink(receiveValue: onReceiveError(_:)).store(in: &cancellables)
        wrapper.anyLocationPublisher.filter(basedOnDistance: distanceFilter).sink(receiveValue: onReceiveLocation(_:)).store(in: &cancellables)
    }

    deinit {
        self.cancellables.forEach {
            $0.cancel()
        }
        self.cancellables.removeAll()
    }
}
