//
//  Vehicle+CoreDataProperties.swift
//  Map
//
//  Created by saj panchal on 2025-02-04.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var batteryCapacity: Double
    @NSManaged public var fuelCost: Double
    @NSManaged public var fuelEfficiency: Double
    @NSManaged public var fuelEngine: String?
    @NSManaged public var fuelMode: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var odometer: Double
    @NSManaged public var odometerMiles: Double
    @NSManaged public var serviceCost: Double
    @NSManaged public var trip: Double
    @NSManaged public var tripHybridEV: Double
    @NSManaged public var tripHybridEVMiles: Double
    @NSManaged public var tripMiles: Double
    @NSManaged public var type: String?
    @NSManaged public var uniqueID: UUID?
    @NSManaged public var year: Int16
    @NSManaged public var fuellings: NSSet?
    @NSManaged public var reports: NSSet?
    @NSManaged public var services: NSSet?
    @NSManaged public var settings: Settings?
    public var getFuelEngine: String {
        fuelEngine ?? "N/A"
    }
    public var getFuelMode: String {
        if fuelMode == nil {
            if fuelEngine == "Gas" {
                return "Gas"
            }
            else if fuelEngine == "EV" {
                return "EV"
            }
            else {
                return "Gas"
            }
        }
        else {
            return fuelMode ?? "Gas"
        }
    }
    public var getOdometerMiles: Double {
        odometer * 0.6214
    }
    public var getTripMiles: Double {
        trip * 0.6214
    }
    public var getTripKm: Double {
        tripMiles / 0.6214
    }
    public var getTripHybridEVMiles: Double {
        tripHybridEV * 0.6214
    }
    public var getMake: String {
        make ?? "N/A"
    }
    public var getVehicleText: String {
        "\(make ?? "") \(model?.replacingOccurrences(of: "_", with: " ") ?? "") \(year)"
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
    public var getFuelEfficiencyMiles: Double {
        fuelEfficiency * 0.6214
    }
    
    public var getBatteryCapacity: Double {
        batteryCapacity == 0.0 ? 40.0 : batteryCapacity
    }
    
    public var getFuellings: [AutoFuelling] {
        let set = fuellings as? Set<AutoFuelling> ?? []
        return set.sorted {
            $0.date! > $1.date!
        }
    }
    
    public var getServices: [AutoService] {
        let set = services as? Set<AutoService> ?? []
        return set.sorted {
            $0.date! > $1.date!
        }
    }
    public var getReports: [AutoSummary] {
        let set = reports as? Set<AutoSummary> ?? []
        return set.sorted {
            $0.calenderYear > $1.calenderYear
        }
    }
    public var getFuellingDates: Set<Date> {
        let set = fuellings as? Set<AutoFuelling> ?? []
        var setDates: Set<Date> = []
        for i in set {
            setDates.insert(i.getShortDate)
        }
        
        return setDates
    }
    public var getServiceDates: Set<Date> {
        let set = services as? Set<AutoService> ?? []
        var setDates: Set<Date> = []
        for i in set {
            setDates.insert(i.getShortDate)
        }
        
        return setDates
    }
    public var getYearsOfVehicleRun: [Int] {
        let serviceDates = getServiceDates
        let fuellingDates = getFuellingDates
        var combineDates: Set<Int> = []
        var years: [Int] = []
        for sd in serviceDates {
            combineDates.insert(Calendar.current.component(.year, from: sd))
        }
        for fd in fuellingDates {
            combineDates.insert(Calendar.current.component(.year, from: fd))
        }
        for cd in combineDates {
            years.append(cd)
        }
        return years
        
    }
    public var getServiceCost: Double {
        var cost = 0.0
        let set = services as? Set<AutoService>
        if let services = set {
                      
            let sorted = services.sorted(by:  {$0.timeStamp ?? Date() > $1.timeStamp ?? Date()})
            let filtered = sorted.filter({Calendar.current.component(.year, from: $0.date!) == Calendar.current.component(.year, from: Date())})
            
            for thisService in filtered {
                cost += thisService.cost
            }
            return cost
        }
       
        return cost
           
    }
    public var getfuelCost: Double {
        var cost = 0.0
        let set = fuellings as? Set<AutoFuelling>
        if let fuellings = set {
                       
            let sorted = fuellings.sorted(by:  {$0.timeStamp ?? Date() > $1.timeStamp ?? Date()})
            let filtered = sorted.filter({Calendar.current.component(.year, from: $0.date!) == Calendar.current.component(.year, from: Date())})
            
            for thisfuelling in filtered {
                cost += thisfuelling.cost
            }
            return cost
        }
        return cost
    }
    
    static func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    static func getResults(viewContext: NSManagedObjectContext) -> [Vehicle] {
        ///call fetchRequest method to fetch AutoSummary records.
        let request = self.fetchRequest()
        ///set the request predicate to get autosummary records associated to a given vehicle.
    //    request.predicate = NSPredicate(format: "isActive == true")
        ///create an empty array of AutoSummary
        var vehicles: [Vehicle] = []
        ///call the viewContext fetch request with a cofigured request object
        do {
          vehicles = try viewContext.fetch(request)
        }
        catch {
            print(error)
        }
        ///return the array.
        return vehicles
    }
    static func AddNewVehicle(viewContext: NSManagedObjectContext, getModel: () -> (VehicleModel)) -> Vehicle? {
        ///create an instance of Vehicle entity
        let model = getModel()
        let vehicles = getResults(viewContext: viewContext)
     
      
        ///create a new vehicle from coredata context
        let newVehicle = Vehicle(context: viewContext)
        ///set new UUID
        newVehicle.uniqueID = UUID()
        ///set vehicle fuel type
        newVehicle.fuelEngine = model.engineType
        ///set vehicle make
        newVehicle.make = model.vehicleMake
        ///set vehicle model
        newVehicle.model = model.model
        ///set vehicle type
        newVehicle.type = model.vehicleType
        ///if vehicle engine is other than Gas type
        if model.engineType != "Gas" {
            ///set the batteryCapacity prop of the vehicle object.
            newVehicle.batteryCapacity = model.batteryCapacity
        }
      
        newVehicle.fuelMode = model.fuelMode
       
        ///set vehicle as not active
        newVehicle.isActive = vehicles.isEmpty
        ///set vehicle year
        newVehicle.year = Int16(model.year)
        ///set vehicle odometer
        newVehicle.odometer = Double(model.odometer)
       
       
        ///set vehicle odometer
        newVehicle.odometerMiles = Double(model.odometerMiles)
    
                
        
        
            ///set new vehicle's trip odometer as trip inputed
            newVehicle.trip = model.trip
           
            ///set new vehicle's trip odometer converted in miles
            newVehicle.tripMiles = model.tripMiles
           
       
        ///if engine type is hybrid set EV props
        if model.engineType == "Hybrid" {
           
                //set vehicle trip odometer
            newVehicle.tripHybridEV = model.tripHybridEV
               
            newVehicle.tripHybridEVMiles = model.tripHybridEVMiles
           
                                
        }
       
       
        return newVehicle
                        
    }
    
    static func updateVehicle(viewContext: NSManagedObjectContext, vehicleIndex: Int, getModel: () -> (VehicleModel)) {
        let vehicles = getResults(viewContext: viewContext)
        let vehicleModel = getModel()
        ///set the vehicle model to new model input
        vehicles[vehicleIndex].model = vehicleModel.model
        vehicles[vehicleIndex].fuelMode = vehicleModel.fuelMode
        ///set the vehicle make to new make input
        vehicles[vehicleIndex].make = vehicleModel.vehicleMake
        ///set the vehicle year to new year input
        vehicles[vehicleIndex].year = Int16(vehicleModel.year)
        ///set the vehicle odometer to new odometer input
        vehicles[vehicleIndex].odometer = vehicleModel.odometer
        ///set the vehicle odometer to new odometer input in miles
        vehicles[vehicleIndex].odometerMiles = vehicleModel.odometerMiles
        ///save the engine type in vehicle object. (Gas, EV, Hybrid)
        vehicles[vehicleIndex].fuelEngine = vehicleModel.engineType
        
        if vehicleModel.engineType == "Hybrid" {
            ///update the hybrid EV trip (in km)
            vehicles[vehicleIndex].tripHybridEV = vehicleModel.tripHybridEV
            vehicles[vehicleIndex].tripHybridEVMiles = vehicleModel.tripHybridEVMiles
        }
        ///update vehicle trip (in miles) with new values
        vehicles[vehicleIndex].tripMiles = vehicleModel.tripMiles
        ///update vehicle trip (in km) with new values
        vehicles[vehicleIndex].trip = vehicleModel.trip
       
        ///if engine type is not gas set the battery capacity of the EV engine
        if vehicleModel.engineType != "Gas" {
            vehicles[vehicleIndex].batteryCapacity = vehicleModel.batteryCapacity
        }
        ///save the vehicle type (Car, Truck, SUV)
        vehicles[vehicleIndex].type = vehicleModel.vehicleType
        Vehicle.saveContext(viewContext: viewContext)
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

// MARK: Generated accessors for reports
extension Vehicle {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: AutoSummary)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: AutoSummary)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

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
