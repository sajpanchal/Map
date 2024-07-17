//
//  Vehicle.swift
//  Map
//
//  Created by saj panchal on 2024-06-26.
//

import Foundation
import SwiftUI

struct AutoVehicle: Identifiable, Hashable {
   
    var id = UUID()
    var make: String?
    var model: String?
    var year: Int?
    var type: String?
    var fuelType: String?
    var odometer: Double?
    var trip: Double?
    var isActive: Bool
    var serviceHistory: [Service]
    var fuelHistory: [FuelData]
    var serviceCost: Double?
    var fuelCost: Double?
}
