//
//  FuelData.swift
//  Map
//
//  Created by saj panchal on 2024-06-22.
//

import Foundation

struct FuelData: Identifiable, Hashable {
    var id: UUID = UUID()
    var location: String?
    var amount: Double?
    var cost: Double?
    var date: Date?
    var dateStamp: String = Date().formatted(date: .long, time: .complete)
}
