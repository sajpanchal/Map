//
//  AutoFuelling+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-07-12.
//
//

import Foundation
import CoreData


extension AutoFuelling {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoFuelling> {
        return NSFetchRequest<AutoFuelling>(entityName: "AutoFuelling")
    }

    @NSManaged public var cost: Double
    @NSManaged public var date: Date?
    @NSManaged public var uniqueID: UUID?
    @NSManaged public var location: String?
    @NSManaged public var timeStamp: Date?
    @NSManaged public var volume: Double
    @NSManaged public var vehicle: Vehicle?
    public var getTimeStamp: String {
        timeStamp?.formatted(date: .long, time: .complete) ?? Date().formatted(date: .long, time: .complete)
    }

}

extension AutoFuelling : Identifiable {

}
