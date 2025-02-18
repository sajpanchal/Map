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
    static func getResults(viewContext: NSManagedObjectContext) -> [Settings] {
        ///call fetchRequest method to fetch AutoSummary records.
        let request = self.fetchRequest()
        ///set the request predicate to get autosummary records associated to a given vehicle.
    //    request.predicate = NSPredicate(format: "isActive == true")
        ///create an empty array of AutoSummary
        var settings: [Settings] = []
        ///call the viewContext fetch request with a cofigured request object
        do {
          settings = try viewContext.fetch(request)
        }
        catch {
            print(error)
        }
        ///return the array.
        return settings
    }
    static func createNewSettings(viewContext: NSManagedObjectContext, for vehicle: Vehicle, getModel: () -> SettingsModel) -> Settings {
        let model = getModel()
        ///create a settings object from viewcontext's settings entity
        let settings = Settings(context: viewContext)
        ///update the preferences for highways
        settings.avoidHighways = model.avoidHighways
        ///update the preferences for tolls
        settings.avoidTolls = model.avoidTolls
        ///assign a current vehicle that is active
        settings.vehicle = vehicle
        ///set the engine type in string format
        settings.autoEngineType = model.autoEngineType
        ///set the distance unit  in string format
        settings.distanceUnit = model.distanceUnit
        ///set the initial distance unit for the MapView API.
        MapViewAPI.distanceUnit = DistanceUnit(rawValue: model.distanceUnit) ?? .km
        ///set the fuel unit in string format
        settings.fuelVolumeUnit = model.fuelVolumeUnit
       
        ///set the efficiency unit  in string format
        settings.fuelEfficiencyUnit = model.fuelEfficiencyUnit
        vehicle.settings = settings
        ///save the managed view context to the core data store with new changes.
        Settings.saveContext(viewContext: viewContext)
        Vehicle.saveContext(viewContext: viewContext)
        return settings
    }
    static func createSettings(viewContext: NSManagedObjectContext, for vehicle: Vehicle, from currentSettings: Settings) -> Settings {
        ///create an instance of Settings entity and insert it to a managed view context.
        let newSettings = Settings(context: viewContext)
        ///set distance unit from currently active vehicle settings to new vehicle settings
        newSettings.distanceUnit = currentSettings.distanceUnit
        ///set engine type from vehicle's set fuel engine type.
        newSettings.autoEngineType = vehicle.getFuelEngine
        ///set highway preference from currently active vehicle settings to new vehicle settings
        newSettings.avoidHighways = currentSettings.avoidHighways
        ///set toll preferencefrom currently active vehicle settings to new vehicle settings
        newSettings.avoidTolls = currentSettings.avoidTolls
        ///if fuel engine is EV type
        if vehicle.getFuelEngine == "EV" {
            ///set settings fuel unit to %
            newSettings.fuelVolumeUnit = "%"
            ///set settings efficiency unit to km/kwh or miles/kwh based on distance unit.
            newSettings.fuelEfficiencyUnit = newSettings.distanceUnit == "km" ? "km/kwh" : "miles/kwh"
        }
        ///if fuel engine is Gas or Hybrid type
        else {
            ///if fuel mode is EV
             if vehicle.fuelMode == "EV" {
                 ///set settings fuel unit to %
                newSettings.fuelVolumeUnit = "%"
                 ///set settings efficiency unit to km/kwh or miles/kwh based on distance unit.
                newSettings.fuelEfficiencyUnit = newSettings.distanceUnit == "km" ? "km/kwh" : "miles/kwh"
            }
            ///if fuel mode is Gas
            else {
                ///set settings fuel unit to Litre
                newSettings.fuelVolumeUnit = "Litre"
                ///set settings efficiency unit to km/L or miles/L based on distance unit.
                newSettings.fuelEfficiencyUnit = newSettings.distanceUnit == "km" ? "km/L" : "miles/L"
            }
        }
        ///set the vehicle in the new settings to newly added vehicle.
        newSettings.vehicle = vehicle
        ///save changes in Settings object(s) to viewcontext parent store.
        Settings.saveContext(viewContext: viewContext)
        return newSettings
    }
    
    static func updateSettings(viewContext: NSManagedObjectContext, for vehicle: Vehicle, getModel: () -> SettingsModel) {
        let settings = getResults(viewContext: viewContext)
        let settingsModel = getModel()
        guard let i = settings.firstIndex(where: {$0.vehicle == vehicle}) else {
            return
        }
        settings[i].distanceUnit = settingsModel.distanceUnit
        settings[i].fuelEfficiencyUnit = settingsModel.fuelEfficiencyUnit
        settings[i].vehicle = vehicle
        settings[i].fuelVolumeUnit = settingsModel.fuelVolumeUnit
        settings[i].autoEngineType = settingsModel.autoEngineType
        
        let vehicles = Vehicle.getResults(viewContext: viewContext)
        guard let vIndex = vehicles.firstIndex(of: vehicle) else {
            return
        }
        vehicles[vIndex].settings = settings[i]
        Settings.saveContext(viewContext: viewContext)
        
    }
}

extension Settings : Identifiable {

}
