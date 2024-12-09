//
//  AutoService+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-07-12.
//
//

import Foundation
import CoreData


extension AutoService {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoService> {
        return NSFetchRequest<AutoService>(entityName: "AutoService")
    }

    @NSManaged public var cost: Double
    @NSManaged public var date: Date?
    @NSManaged public var details: String?
    @NSManaged public var uniqueID: UUID?
    @NSManaged public var location: String?
    @NSManaged public var timeStamp: Date?
    @NSManaged public var type: String?
    @NSManaged public var vehicle: Vehicle?
    public var getDateString: String {
        date?.formatted(date: .long, time: .omitted) ?? Date().formatted(date: .long, time: .omitted)
    }
    public var getTimeStamp: String {
        timeStamp?.formatted(date: .long, time: .complete) ?? Date().formatted(date: .long, time: .complete)
    }

}

extension AutoService : Identifiable {

}
