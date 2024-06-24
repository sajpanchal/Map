//
//  AutoService.swift
//  Map
//
//  Created by saj panchal on 2024-06-24.
//

import Foundation

struct AutoService: Identifiable {
    var id = UUID()
    var location: String?
    var type: String?
    var description: String?
    var cost: Double?
    var date: Date?
    var timeStamp: String = Date().formatted(date: .long, time: .complete)
}
