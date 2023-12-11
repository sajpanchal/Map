//
//  MapSwiftUIAPI.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import Foundation

func getDirectionSign(for step: String) -> String {
    let instruction = step.lowercased()
    print("instruction is: \(instruction)")
    if instruction.contains("turn left") {
        return "arrow.turn.up.left"
    }
    else if instruction.contains("turn right")
    {
        return "arrow.turn.up.right"
    }
    else if instruction.contains("slight left") {
        return "arrow.turn.left.up"
    }
    else if instruction.contains("slight right") {
        return "arrow.turn.right.up"
    }
    else if instruction.contains("keep right") {
        return "rectangle.righthalf.inset.filled.arrow.right"
    }
    else if instruction.contains("keep left") {
        return "rectangle.lefthalf.inset.filled.arrow.left"
    }
    else if instruction.contains("continue") {
        return "arrow.up"
    }
    else if instruction.contains("first exit") {
        return "1.circle"
    }
    else if instruction.contains("second exit") {
        return "2.circle"
    }
    else if instruction.contains("third exit") {
        return "3.circle"
    }
    else if instruction.contains("make a u-turn"){
        return "arrow.uturn.down"
    }
    else if instruction.contains("fourth exit") {
     return "4.circle"
    }
    else if instruction.contains("exit") {
        return "arrow.up.right"
    }
    else if instruction.contains("starting at")
    {
        return "location.north.line"
    }
    else if instruction.contains("arrive") || instruction.contains("arrived") {
        return "mappin.and.ellipse"
    }
    else if instruction.contains("destination") {
        return "mappin.and.ellipse"
    }
    return ""
}

func convertToString(from number: Double) -> String {
    var number = number
    if number > 1000 {
       number = number/1000
        return String(format:"%.1f", number) + " km"
    }
    else {
       let num = Int(number)
        return String(num) + " m"
    }
}


