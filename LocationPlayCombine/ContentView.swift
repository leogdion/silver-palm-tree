//
//  ContentView.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import CoreLocation
import SwiftUI
extension CLAuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorizedAlways:
      return "Always"
    case .authorizedWhenInUse:
      return "When In Use"
    case .denied:
      return "Denied"
    case .notDetermined:
      return "Not Determined"
    case .restricted:
      return "Restricted"
    @unknown default:
      return "🤷‍♂️"
    }
  }
}
struct ContentView: View {
  @ObservedObject var object  = CoreLocationManager()
  
    var body: some View {
      VStack{
        Text(self.object.authorizationStatus.description)
        Text(self.object.lastLocation?.description ?? "")
        Text(self.object.locationFailure?.localizedDescription ?? "")
      }
        
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
