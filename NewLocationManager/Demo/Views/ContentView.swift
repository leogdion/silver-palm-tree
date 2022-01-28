import Combine
import CoreLocation
import SwiftUI

struct ContentView: View {
  @EnvironmentObject var model: Object
  var body: some View {
    NavigationView {
      List {
        ForEach(self.model.locations) { data in
          Text(data.location.debugDescription)
        }
      }
      .padding().toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("\(model.authorizationStatus.description)") {
            DispatchQueue.main.async {
              self.model.requestAuthorization()
            }
          }.disabled(model.authorizationStatus != .notDetermined)
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          // Text("\(self.model.counter)")
          Button("Add") {
            model.add()
          }
          Button("Remove") {
            model.remove()
          }
        }
      }
    }
  }
}
