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
        lasttrip * 0.6214
    }
    
    public var getLastTripKm: Double {
        lastTripMiles / 0.6214
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
    public var getShortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
       return formatter.string(from: date ?? Date())
    }
    public var getShortDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let str = formatter.string(from: date ?? Date())
        return formatter.date(from: str) ?? Date()
    }
    public var getYearFromDate: Int {
       
        let year = Calendar.current.component(.year, from: date ?? Date())
       
        return year
    }
}

extension AutoFuelling : Identifiable {

}
