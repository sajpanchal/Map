//
//  Vehicle+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2024-07-16.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var fuelEngine: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var odometer: Double
    @NSManaged public var trip: Double
    @NSManaged public var type: String?
    @NSManaged public var uniqueID: UUID?
    @NSManaged public var year: Int16
    @NSManaged public var fuelCost: Double
    @NSManaged public var serviceCost: Double
    @NSManaged public var fuellings: NSSet?
    @NSManaged public var services: NSSet?
    
    public var getFuelEngine: String {
        fuelEngine ?? "N/A"
    }
    
    public var getMake: String {
        make ?? "N/A"
    }
    public var getVehicleText: String {
        "\(make ?? "") \(model?.replacingOccurrences(of: "_", with: " ") ?? "")"
    }
    public var getModel: String {
        model ?? "N/A"
    }
    
    public var getType: String {
        type ?? "N/A"
    }
    public var getYear: String {
        String(year)
    }
    
    
    public var getFuellings: [AutoFuelling] {
        let set = fuellings as? Set<AutoFuelling> ?? []
        return set.sorted {
            $0.timeStamp! > $1.timeStamp!
        }
    }
    
    public var getServices: [AutoService] {
        let set = services as? Set<AutoService> ?? []
        return set.sorted {
            $0.timeStamp! > $1.timeStamp!
        }
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

// MARK: Generated accessors for fuellings
extension Vehicle {

    @objc(addFuellingsObject:)
    @NSManaged public func addToFuellings(_ value: AutoFuelling)

    @objc(removeFuellingsObject:)
    @NSManaged public func removeFromFuellings(_ value: AutoFuelling)

    @objc(addFuellings:)
    @NSManaged public func addToFuellings(_ values: NSSet)

    @objc(removeFuellings:)
    @NSManaged public func removeFromFuellings(_ values: NSSet)

}

// MARK: Generated accessors for services
extension Vehicle {

    @objc(addServicesObject:)
    @NSManaged public func addToServices(_ value: AutoService)

    @objc(removeServicesObject:)
    @NSManaged public func removeFromServices(_ value: AutoService)

    @objc(addServices:)
    @NSManaged public func addToServices(_ values: NSSet)

    @objc(removeServices:)
    @NSManaged public func removeFromServices(_ values: NSSet)

}

extension Vehicle : Identifiable {

}
