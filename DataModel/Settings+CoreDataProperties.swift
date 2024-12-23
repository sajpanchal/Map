//
//  Settings+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-12-21.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var autoEngineType: String?
    @NSManaged public var distanceUnit: String?
    @NSManaged public var fuelEfficiencyUnit: String?
    @NSManaged public var fuelVolumeUnit: String?
    @NSManaged public var avoidHighways: Bool
    @NSManaged public var avoidTolls: Bool
    @NSManaged public var vehicle: Vehicle?
    public var getAutoEngineType: String {
        autoEngineType ?? "n/a"
    }
    public var getDistanceUnit: String {
        distanceUnit ?? "n/a"
    }
    public var getFuelEfficiencyUnit: String {
        fuelEfficiencyUnit ?? "n/a"
    }
    public var getFuelVolumeUnit: String {
        fuelVolumeUnit ?? "n/a"
    }
    
    static func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension Settings : Identifiable {

}
