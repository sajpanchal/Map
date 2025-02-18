//
//  VehicleModel.swift
//  Map
//
//  Created by saj panchal on 2025-02-10.
//

import Foundation
struct VehicleModel {
    var vehicleType: String
    var vehicleMake: String
    var model: String
    var year: Int
    var engineType: String
    var batteryCapacity: Double
    var odometer: Double
    var odometerMiles: Double
    var trip: Double
    var tripMiles: Double
    var tripHybridEV: Double
    var tripHybridEVMiles: Double
    var fuelMode: String
}

struct SettingsModel {
    var autoEngineType: String
    var distanceUnit: String
    var fuelEfficiencyUnit: String
    var fuelVolumeUnit: String
    var avoidHighways: Bool
    var avoidTolls: Bool
 
}
