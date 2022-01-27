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
  
  let tracker : Tracker
  
  func request(_ demand: Subscribers.Demand) {
    
  }
  
  func cancel() {
    self.tracker.subscriptionWillCancel(self)
  }
  
  
}


class TrackablePublisher<Value> : Publisher {
  var tracker : Tracker?
  
  internal init() {
    self.subject = PassthroughSubject()
  }
  
  func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Value == S.Input {
    let subscription = TrackableSubscription<Value>(tracker: self.tracker!)
    subscriber.receive(subscription: subscription)
    self.tracker?.subscriptionWasReceived(subscription)
  }
  

  
  typealias Output = Value
  
  typealias Failure = Never
  
  let subject : PassthroughSubject<Value,Never>
}


class CoreLocationManager : LocationManager {
  var errorPublisher: AnyPublisher<Error, Never> {
    provider.errorPublisher
  }
  
  var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
    return provider.authorizationPublisher
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
  internal override init() {
    let manager = CLLocationManager()
    self.manager = manager
    
    authorizationPublisher = Just(.notDetermined)
      .merge(with:
        authorizationSubject
      ).eraseToAnyPublisher()

    locationPublisher = locationSubject.eraseToAnyPublisher()
    errorPublisher = errorSubject.eraseToAnyPublisher()
    
    super.init()
    
    manager.delegate = self
    self.authorizationSubject.tracker = self
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
  
  let authorizationSubject = TrackablePublisher<CLAuthorizationStatus>()

  let locationSubject = TrackablePublisher<[CLLocation]>()
  
  let errorSubject = TrackablePublisher<Error>()
  
  
  
}
protocol LocationManager {
  var errorPublisher : AnyPublisher<Error, Never> { get }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
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
  
  init (locations : [LocationData] = .init()) {
    self.provider = CoreLocationManagerProvider()
    self.locations = locations
    
    self.provider.$counter.assign(to: &self.$counter)
  }
  
  func add () {
    let manager = provider.createManager()
    locations.append(.init(manager: manager))
  }
  
  func remove () {
    _ = locations.popLast()
  }
}

class LocationData : Identifiable, ObservableObject {
//  static func forPreview(withLocation location: CLLocation) -> LocationData {
//    return .init(manager: MockLocationManager(), location: location)
//  }
  internal init(manager: LocationManager, id: UUID = .init(), authorizationStatus: CLAuthorizationStatus = .notDetermined, location : CLLocation? = nil, error : Error? = nil) {
    self.id = id
    self.manager = manager
    self.location = location
    self.authorizationStatus = authorizationStatus
    self.error = error
    
    manager.errorPublisher.map{ $0 as Error? }.assign(to: &self.$error)
    manager.authorizationPublisher.assign(to: &self.$authorizationStatus)
    manager.locationPublisher.map{ $0 as CLLocation? }.assign(to: &self.$location)
  }
  
  let id : UUID
  let manager : LocationManager
  @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
  @Published var location : CLLocation?
  @Published var error : Error?
}

struct ContentView: View {
  @EnvironmentObject var model : Object
    var body: some View {
      NavigationView {
        List(self.model.locations, rowContent: { location in
          Text(location.location?.description ?? "No Location")
        })
            .padding().toolbar {
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
