//
//  AutoFuelling+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-10-05.
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
    @NSManaged public var fuelType: String?
    @NSManaged public var gallon: Double
    @NSManaged public var lasttrip: Double
    @NSManaged public var litre: Double
    @NSManaged public var location: String?
    @NSManaged public var percent: Double
    @NSManaged public var timeStamp: Date?
    @NSManaged public var uniqueID: UUID?
    @NSManaged public var lastTripMiles: Double
    @NSManaged public var vehicle: Vehicle?
    public var getLastTripMiles: Double {
        lasttrip * 0.62
    }
    
    public var getLastTripKm: Double {
        lastTripMiles / 0.62
    }
    public var getVolumeGallons: Double {
        litre / 3.785
    }
    public var getVolumeLitre: Double {
        gallon * 3.785
    }
    public var getDateString: String {
        date?.formatted(date: .long, time: .omitted) ?? Date().formatted(date: .long, time: .omitted)
    }
    public var getTimeStamp: String {
        timeStamp?.formatted(date: .long, time: .complete) ?? Date().formatted(date: .long, time: .complete)
    }
}

extension AutoFuelling : Identifiable {

}
