//
//  RouteData.swift
//  Map
//
//  Created by saj panchal on 2024-03-22.
//

import Foundation

struct RouteData: Identifiable, Equatable {
    var id: UUID = UUID ()
    var travelTime: String = ""
    var distance: String = ""
    var title: String = ""
    var tapped: Bool = false
    var uniqueString : String = ""
}
