//
//  Untitled.swift
//  Map
//
//  Created by saj panchal on 2025-01-05.
//
import Foundation
struct VehicleData: Identifiable, Hashable {  
    var uniqueID: UUID?
    let id: UUID = UUID()
    var text: String = ""
    var engineType: String = ""
}
