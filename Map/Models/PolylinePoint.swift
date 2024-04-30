//
//  PolylinePoint.swift
//  Map
//
//  Created by saj panchal on 2024-04-17.
//

import Foundation
import MapKit
struct PolylinePoint {
    var point: MKMapPoint
    var isPointEntered = false
    var isPointExited = false
    var prevDistance: Int?
    var currentDistance: Int?
   
}
