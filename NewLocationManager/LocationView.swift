import Combine
import Foundation
import SwiftUI

struct LocationView: View {
  internal init(id: UUID) {
    self.id = id
  }

  @EnvironmentObject var model: Object
  let id: UUID
  var index: Int? {
    model.locations.firstIndex(where: {
      $0.id == id
    })
  }

  var data: LocationData? {
    index.map {
      model.locations[$0]
    }
  }

  var body: some View {
    Text(data?.location?.description ?? "No Location")
  }
}
