//
//  LocationManager.swift
//  LocationPlayCombine
//
//  Created by Leo Dion on 1/7/22.
//

import Combine
import CoreLocation
import Foundation

/// SwiftUI Observable Object of `LocationManager`
public protocol ObservableLocationManager: ObservableObject, LocationManager {}
