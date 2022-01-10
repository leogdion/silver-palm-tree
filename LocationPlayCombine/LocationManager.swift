//
//  LocationManager.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import Foundation
import CoreLocation
import Combine


protocol ObservableLocationManager : ObservableObject, LocationManager {
  
}
protocol LocationManager  {
  associatedtype LocationValuePublisher : Publisher where LocationValuePublisher.Output == CLLocation, LocationValuePublisher.Failure == Never
  associatedtype LocationErrorPublisher : Publisher where LocationErrorPublisher.Output == Error, LocationErrorPublisher.Failure == Never
  associatedtype ManagerErrorPublisher : Publisher where ManagerErrorPublisher.Output == LocationManagerError, ManagerErrorPublisher.Failure == Never
  associatedtype AuthorizationStatusPublisher : Publisher where AuthorizationStatusPublisher.Output == CLAuthorizationStatus, AuthorizationStatusPublisher.Failure == Never
  var lastLocation : CLLocation? { get }
  var lastError: Error? { get }
  var managerError: LocationManagerError? { get }
  var authorizationStatus: CLAuthorizationStatus { get }
  
  var locationPublisher : LocationValuePublisher { get }
  var lcationErrorPublisher : LocationErrorPublisher { get }
  var managerErrorPublisher: ManagerErrorPublisher { get }
  var authorizationStatusPublisher: AuthorizationStatusPublisher { get }

}
