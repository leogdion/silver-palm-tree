//
//  ContentView.swift
//  NewLocationManager
//
//  Created by Leo Dion on 1/27/22.
//

import SwiftUI
import CoreLocation
import Combine



protocol Tracker {
  func subscriptionWillCancel<Value>(_ subscription: TrackableSubscription<Value>)
  func subscriptionWasReceived<Value>(_ subscription: TrackableSubscription<Value>)
}

class TrackableSubscription<Value> : Subscription {
  internal init(tracker: Tracker) {
    self.tracker = tracker
  }
  
  var tracker : Tracker?
  
  func request(_ demand: Subscribers.Demand) {
    
  }
  
  func cancel() {
    self.tracker?.subscriptionWillCancel(self)
    tracker = nil
  }
  
 
}


class TrackablePublisher<Value> : Publisher {
  var tracker : Tracker?
  var cancellables = [AnyCancellable]()
  
  internal init() {
    self.subject = PassthroughSubject()
  }
  
  func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Value == S.Input {
    
    let subscription = TrackableSubscription<Value>(tracker: self.tracker!)
    subject.send(subscription: subscription)
    subscriber.receive(subscription: subscription)
    subject.sink { value in
      subscriber.receive(value)
    }.store(in: &cancellables)
    self.tracker?.subscriptionWasReceived(subscription)
  }
  
  
  func send(_ input: Value) {
    subject.send(input)
  }

  
  typealias Output = Value
  
  typealias Failure = Never
  
  let subject : PassthroughSubject<Value,Never>
}


class CoreLocationManager : LocationManager {
  var errorPublisher: AnyPublisher<Error, Never> {
    provider.errorPublisher
  }
  
  
  var locationPublisher: AnyPublisher<CLLocation, Never> {
    return provider.locationPublisher.flatMap(
      Publishers.Sequence.init
    ).eraseToAnyPublisher()
  }
  

  
  
  internal init(provider: CoreLocationManagerProvider) {
    self.provider = provider
    
    
  }
  
  let provider : CoreLocationManagerProvider
}
class CoreLocationManagerProvider : NSObject, LocationManagerProvider, CLLocationManagerDelegate, Tracker {
  
  @Published var counter : Int = 0 {
    didSet {
      if oldValue == 0 && self.counter > 0 {
        self.manager.startUpdatingLocation()
      } else if oldValue > 0 && self.counter == 0 {
        self.manager.stopUpdatingLocation()
      }
    }
  }
  
  func subscriptionWasReceived<Value>(_ subscription: TrackableSubscription<Value>) {
    counter += 1
  }
  func subscriptionWillCancel<Value>(_ subscription: TrackableSubscription<Value>) {
    counter -= 1
  }
  
  func requestAuthorization () {
    self.manager.requestWhenInUseAuthorization()
  }
  internal override init() {
    let manager = CLLocationManager()
    self.manager = manager
    
    authorizationPublisher = Just(manager.authorizationStatus)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()

    locationPublisher = locationSubject.eraseToAnyPublisher()
    errorPublisher = errorSubject.eraseToAnyPublisher()
    
    super.init()
    
    manager.delegate = self
    self.locationSubject.tracker = self
    self.errorSubject.tracker = self
    
  }
  
  let manager : CLLocationManager
  
  public let errorPublisher : AnyPublisher<Error, Never>

  public let authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never>

  public let locationPublisher: AnyPublisher<[CLLocation], Never>
  
  
  func createManager() -> LocationManager {
    return CoreLocationManager(provider: self)
  }
  
  let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()

  let locationSubject = TrackablePublisher<[CLLocation]>()
  
  let errorSubject = TrackablePublisher<Error>()
  
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.authorizationSubject.send(manager.authorizationStatus)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.locationSubject.send(locations)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.errorSubject.send(error)
  }
}
protocol LocationManager {
  var errorPublisher : AnyPublisher<Error, Never> { get }
      var locationPublisher: AnyPublisher<CLLocation, Never> { get }
}


protocol LocationManagerProvider {
  func createManager () -> LocationManager
  var errorPublisher : AnyPublisher<Error, Never> { get }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
      var locationPublisher: AnyPublisher<[CLLocation], Never> { get }
  
  
}
class Object : ObservableObject {
  let provider : CoreLocationManagerProvider
  @Published var locations : [LocationData]
  @Published var counter : Int = 0
  @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  
  init (locations : [LocationData] = .init()) {
    self.provider = CoreLocationManagerProvider()
    self.locations = locations
    
    
    self.provider.authorizationPublisher.assign(to: &self.$authorizationStatus)
    self.provider.$counter.assign(to: &self.$counter)
  }
  
  func add () {
    let manager = provider.createManager()
    locations.append(.init(manager: manager))
  }
  
  func remove () {
    _ = locations.popLast()
  }
  
  func requestAuthorization () {
    self.provider.requestAuthorization()
  }
}

class LocationData : Identifiable, ObservableObject {
//  static func forPreview(withLocation location: CLLocation) -> LocationData {
//    return .init(manager: MockLocationManager(), location: location)
//  }
  internal init(manager: LocationManager, id: UUID = .init(), location : CLLocation? = nil, error : Error? = nil) {
    self.id = id
    self.manager = manager
    self.location = location
    //self.authorizationStatus = authorizationStatus
    self.error = error
    
    manager.errorPublisher.map{ $0 as Error? }.receive(on: DispatchQueue.main).assign(to: &self.$error)
    //manager.authorizationPublisher.assign(to: &self.$authorizationStatus)
    manager.locationPublisher.map{ $0 as CLLocation? }.receive(on: DispatchQueue.main).assign(to: &self.$location)
  }
  
  let id : UUID
  let manager : LocationManager
  //@Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  @Published var location : CLLocation?
  @Published var error : Error?
}

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

struct LocationView : View {
  internal init(id: UUID) {
    self.id = id
  }
  
  @EnvironmentObject var model : Object
  let id : UUID
  var index : Int? {
   self.model.locations.firstIndex(where: {
      $0.id == id
    })
  }
  
  
  
  var data : LocationData? {
    index.map{
      model.locations[$0]
    }
  }
  var body: some View {
    Text(data?.location?.description ?? "No Location")
  }
  
  
}
struct ContentView: View {
  @EnvironmentObject var model : Object
    var body: some View {
      NavigationView {
        List{
        ForEach(self.model.locations) {
          LocationView(id: $0.id)
        }
        }
//        List(self.model.locations.keys, rowContent: { location in
//          LocationView(id: location.id)
//        })
            .padding().toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                Button("\(model.authorizationStatus.description)") {
                  DispatchQueue.main.async {
                    self.model.requestAuthorization()
                    
                  }
                }.disabled(model.authorizationStatus != .notDetermined)
              }
              ToolbarItemGroup(placement: .navigationBarTrailing){
                Text("\(self.model.counter)")
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
