import Combine

extension Publisher {
  func lastItemsWith(count: Int) -> Publishers.Filter<Publishers.Scan<Self, [Output]>> {
    self.scan([]) {
      return $0.suffix(count - 1) + [$1]
    }.filter{ $0.count == count }
  }
}
