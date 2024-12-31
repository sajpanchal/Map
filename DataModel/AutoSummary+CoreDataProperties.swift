//
//  AutoSummary+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-12-27.
//
//

import Foundation
import CoreData


extension AutoSummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoSummary> {
        return NSFetchRequest<AutoSummary>(entityName: "AutoSummary")
    }

    @NSManaged public var annualFuelCost: Double //
    @NSManaged public var annualfuelCostEV: Double//
    @NSManaged public var annualMileage: Double
    @NSManaged public var annualMileageEV: Double
    @NSManaged public var annualServiceCost: Double
    @NSManaged public var annualServiceCostEV: Double
    @NSManaged public var annualTrip: Double //
    @NSManaged public var annualTripEV: Double //
    @NSManaged public var calenderYear: Int16
    @NSManaged public var litreConsumed: Double //
    @NSManaged public var kwhConsumed: Double //
    @NSManaged public var odometerEnd: Double
    @NSManaged public var odometerStart: Double
    @NSManaged public var annualTripMiles: Double //
    @NSManaged public var annualTripEVMiles: Double //
    @NSManaged public var gallonsConsumed: Double //
    @NSManaged public var odometerStartMiles: Double
    @NSManaged public var odometerEndMiles: Double
    @NSManaged public var vehicle: Vehicle?
    var getCalenderYear: String {
        String(calenderYear)
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

extension AutoSummary : Identifiable {

}
