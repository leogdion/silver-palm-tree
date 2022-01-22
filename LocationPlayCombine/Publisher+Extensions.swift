import Combine
import CoreLocation

public extension Publisher {
    /// Grab the last set of items from the publisher.
    /// - Parameter count: How many items to collect
    /// - Returns: An a publisher which returns an array of items.
    func lastItemsWith(count: Int) -> Publishers.Filter<Publishers.Scan<Self, [Output]>> {
        scan([]) {
            return $0.suffix(count - 1) + [$1]
        }.filter { $0.count == count }
    }

    /// Filters a CLLocation publisher based on the distance of the last two items.
    /// - Parameter distanceFilter: The number of meters to filter coordinate distances.
    /// - Returns: New publisher filtered based on the distance.
    func filter(basedOnDistance distanceFilter: CLLocationDistance)  -> Publishers.CompactMap<Publishers.Filter<Publishers.Scan<Self, [CLLocation]>>, CLLocation>
        where Self.Output == CLLocation
    {
        lastItemsWith(count: 2).compactMap { locations in

            guard let lhs = locations.first, let rhs = locations.last else {
                return nil
            }

            guard distanceFilter != kCLDistanceFilterNone else {
                return rhs
            }

            guard abs(lhs.distance(from: rhs)) > distanceFilter else {
                return nil
            }

            return rhs
        }
    }
}
