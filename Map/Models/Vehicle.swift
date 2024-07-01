//
//  Vehicle.swift
//  Map
//
//  Created by saj panchal on 2024-06-26.
//

import Foundation
import SwiftUI

struct Vehicle: Identifiable, Hashable {
    var id = UUID()
    var make: String?
    var model: String?
    var year: String?
    var type: String?
    var fuelType: String?
    var image: String?
    
}
