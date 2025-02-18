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

    @NSManaged public var annualFuelCost: Double
    @NSManaged public var annualfuelCostEV: Double
    @NSManaged public var annualMileage: Double
    @NSManaged public var annualMileageEV: Double
    @NSManaged public var annualServiceCost: Double
    @NSManaged public var annualServiceCostEV: Double
    @NSManaged public var annualTrip: Double
    @NSManaged public var annualTripEV: Double
    @NSManaged public var calenderYear: Int16
    @NSManaged public var litreConsumed: Double
    @NSManaged public var kwhConsumed: Double
    @NSManaged public var odometerEnd: Double
    @NSManaged public var odometerStart: Double
    @NSManaged public var annualTripMiles: Double
    @NSManaged public var annualTripEVMiles: Double
    @NSManaged public var gallonsConsumed: Double
    @NSManaged public var odometerStartMiles: Double
    @NSManaged public var odometerEndMiles: Double
    @NSManaged public var vehicle: Vehicle?
    
    ///get calendar Year in string format
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
    
    ///get an array of AutoSummary from the viewContext
    static func getResults(viewContext: NSManagedObjectContext, vehicle: Vehicle) -> [AutoSummary] {
        ///call fetchRequest method to fetch AutoSummary records.
        let request = self.fetchRequest()
        ///set the request predicate to get autosummary records associated to a given vehicle.
        request.predicate = NSPredicate(format: "vehicle == %@", vehicle)
        ///create an empty array of AutoSummary
        var reports: [AutoSummary] = []
        ///call the viewContext fetch request with a cofigured request object
        do {
          reports = try viewContext.fetch(request)
        }
        catch {
            print(error)
        }
        ///return the array.
        return reports
    }
    
    ///method to accumulate the fuel efficiency for a given year.
    static func setFuelEfficiency(viewContext: NSManagedObjectContext, vehicle: Vehicle, settings: Settings) {
       ///get the autosummary reports  for a given vehicle
        let reports = getResults(viewContext: viewContext, vehicle: vehicle)
        
        ///guard if reports are empty and return function call.
        guard !reports.isEmpty else {
            return
        }
        
        ///iterate through reports array
        for report in reports {
            ///get the report index of a given report.
            guard let reportIndex = reports.firstIndex(of: report) else {
                return
            }
            ///if vehicle is hybrid type
            if vehicle.fuelEngine == "Hybrid" {
                ///call the get fuel efficiency method to get accumulated efficiency for  a given calender year for Gas engine mode. save the results in annual mileage prop.
                reports[reportIndex].annualMileage = getFuelEfficiency(year: Int(report.calenderYear), fuelMode: "Gas", vehicle: vehicle, settings: settings)
                ///call the get fuel efficiency method to get accumulated efficiency for  a given calender year for EV engine mode. save the results in annual mileage EV prop.
                reports[reportIndex].annualMileageEV = getFuelEfficiency(year: Int(report.calenderYear), fuelMode: "EV", vehicle: vehicle, settings: settings)
            }
            ///if vehicle is not hybrid type
            else {
                ///if the fuel engine is gas type
                if vehicle.fuelEngine == "Gas" {
                    ///call the get fuel efficiency method to get accumulated efficiency for  a given calender year for Gas engine mode. save the results in annual mileage prop.
                    reports[reportIndex].annualMileage = getFuelEfficiency(year: Int(report.calenderYear), fuelMode: "Gas", vehicle: vehicle, settings: settings)
                }
                ///if the fuel engine is EV type.
                else {
                    ///call the get fuel efficiency method to get accumulated efficiency for  a given calender year for EV engine mode. save the results in annual mileage EV prop.
                    reports[reportIndex].annualMileageEV = getFuelEfficiency(year: Int(report.calenderYear), fuelMode: "EV", vehicle: vehicle, settings: settings)
                }
            }
        }
        ///save the context
        AutoSummary.saveContext(viewContext: viewContext)
    }
    
    ///
    static func getFuelEfficiency(year: Int, fuelMode: String, vehicle: Vehicle, settings: Settings) -> Double {
        ///local variable to calculate accumulated vehicle trips
        var accumulatedTrip = 0.0
        ///local variable to calculate accumulated fuel volume
        var accumulatedFuelVolume = 0.0
        ///local variable to calculate the efficiency by year.
        var efficiency = 0.0
        
        ///iterate through the fuelling entries filtered by vehicle fuel mode (gas or ev)
        for fuelling in vehicle.getFuellings.filter({$0.fuelType == fuelMode && Calendar.current.component(.year, from: $0.date!) == year}) {
            ///if the distance unit is set to km
            if settings.distanceUnit == "km" {
                ///caculate the trip total in km
                accumulatedTrip += fuelling.lasttrip != 0 ? fuelling.lasttrip : fuelling.getLastTripKm
            }
            ///if the distance unit is set to miles
            else if settings.distanceUnit == "miles" {
                ///calculate the trip total in miles. if trip in miles is 0 then get it converted from trip in km.
                accumulatedTrip += fuelling.lastTripMiles != 0 ?  fuelling.lastTripMiles :  fuelling.getLastTripMiles
            }
            ///if the fuel volume is set to litre
            if fuelMode == "Gas" {
                if settings.getFuelVolumeUnit == "Litre" {
                    ///calculate the fuelling volume total in litre
                    accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
                }
                ///if the fuel volume is set to gallon
                else if settings.getFuelVolumeUnit == "Gallon" {
                    ///calculate the fuelling volume total in gallon
                    accumulatedFuelVolume += fuelling.gallon != 0 ? fuelling.gallon : fuelling.getVolumeGallons
                }
                else {
                    accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
                }
            }
            ///if the fuel volume  unit is set to percentage
            else {
                ///calculate the fuel volume in  % of  battery charged.
                accumulatedFuelVolume += (fuelling.percent * vehicle.batteryCapacity)/100
            }
        }
        ///now calcuate the fuel efficiency from the accumulated trip divided by fuel volume.
        efficiency = accumulatedTrip/accumulatedFuelVolume
        
        if let efficiencyUnit = settings.fuelEfficiencyUnit {
            if efficiencyUnit == "L/100km" || efficiencyUnit == "L/100miles" || efficiencyUnit == "gl/100km" || efficiencyUnit == "gl/100miles" {
                efficiency  = 100/efficiency
            }
        }
      ///return the value.
        return efficiency
    }
    
    
    static func accumulateFuellingsAndTravelSummary(viewContext: NSManagedObjectContext, in settings: Settings, for vehicle: Vehicle, year: Int, cost: Double, amount: Double) {
        ///get the reports from the viewcontext
        let reports = getResults(viewContext: viewContext, vehicle: vehicle)
        
        ///if reports array have a report index for a given vehicle and calendar year.
        if let reportIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == year}) {
            ///reset all props.
            reports[reportIndex].annualTrip = 0
            reports[reportIndex].annualTripMiles = 0
            reports[reportIndex].annualTripEV = 0
            reports[reportIndex].annualTripEVMiles = 0
            reports[reportIndex].litreConsumed = 0
            reports[reportIndex].gallonsConsumed = 0
            reports[reportIndex].kwhConsumed = 0
            reports[reportIndex].annualFuelCost = 0
            reports[reportIndex].annualfuelCostEV = 0
            
            ///iterate through fuellings array for a given calendar year.
            for fuelling in vehicle.getFuellings.filter({Calendar.current.component(.year, from: $0.date!) == year}) {
                ///if fuel type is gas
                if fuelling.fuelType == FuelMode.Gas.rawValue {
                    ///accumulate the trip
                    reports[reportIndex].annualTrip += fuelling.lasttrip
                    ///acuumulate the trip in miles
                    reports[reportIndex].annualTripMiles += fuelling.lastTripMiles
                    ///accumulate the fuel cost
                    reports[reportIndex].annualFuelCost += fuelling.cost
                }
                ///if fuel type is EV
                else {
                    ///accumulate the trip
                    reports[reportIndex].annualTripEV += fuelling.lasttrip
                    ///acuumulate the trip in miles
                    reports[reportIndex].annualTripEVMiles += fuelling.lastTripMiles
                    ///accumulate the fuel cost
                    reports[reportIndex].annualfuelCostEV += fuelling.cost
                }
                ///accumulate litres of fuel consumed
                reports[reportIndex].litreConsumed += fuelling.litre
                ///accumulate gallons of fuel consumed
                reports[reportIndex].gallonsConsumed += fuelling.gallon
                ///accumulate kwh of ev charge consumed
                reports[reportIndex].kwhConsumed += (vehicle.batteryCapacity * fuelling.percent)/100
            }
            ///update the odometer end readings with latest odometer readings of a vehicle
            reports[reportIndex].odometerEnd = vehicle.odometer
            ///update the odometer end readings with latest odometer readings of a vehicle in miles
            reports[reportIndex].odometerEndMiles = vehicle.odometerMiles
            ///save the context.
            Vehicle.saveContext(viewContext: viewContext)
        }
        ///if there is no autosummary report found for a given calandar year.
        else {
            ///create an autosummary object.
            let autoSummary = AutoSummary(context: viewContext)
            ///set a calendar year to a year of interest.
            autoSummary.calenderYear = Int16(year)
            ///if fuel engine is hybrid type
            if vehicle.getFuelEngine == "Hybrid" {
                ///if vehicle is currenty having gas mode
                if vehicle.getFuelMode == "Gas" {
                    ///set the vehicle trip as annual trip
                    autoSummary.annualTrip = vehicle.trip
                    ///set the vehicle trip as annual trip in miles
                    autoSummary.annualTripMiles = vehicle.tripMiles
                    ///set the fuel cost as annual fuel cost.
                    autoSummary.annualFuelCost = cost
                }
                ///if vehicle is currenty having EV mode.
                else {
                    ///set the vehicle trip as annual trip EV
                    autoSummary.annualTripEV = vehicle.tripHybridEV
                    ///set the vehicle trip as annual trip in miles EV
                    autoSummary.annualTripEVMiles = vehicle.tripHybridEVMiles
                    ///set the fuel cost as annual fuel cost EV.
                    autoSummary.annualfuelCostEV = cost
                }
            }
            ///if fuel engine is Gas type
            else if vehicle.getFuelEngine == "Gas" {
                ///set the vehicle trip as annual trip
                autoSummary.annualTrip = vehicle.trip
                ///set the vehicle trip as annual trip in miles
                autoSummary.annualTripMiles = vehicle.tripMiles
                ///set the fuel cost as annual fuel cost.
                autoSummary.annualFuelCost = cost
            }
            ///if fuel engine is EV type
            else {
                ///set the vehicle trip as annual trip EV
                autoSummary.annualTripEV = vehicle.trip
                ///set the vehicle trip as annual trip in miles EV
                autoSummary.annualTripEVMiles = vehicle.tripMiles
                ///set the fuel cost as annual fuel cost EV.
                autoSummary.annualFuelCost = cost
            }
            ///if the fuel volume unit is set to litre.
            if settings.getFuelVolumeUnit == "Litre" {
                ///set amount as litre consumed annually
                autoSummary.litreConsumed = amount
                ///set converted amount as gallonsconsumed annually
                autoSummary.gallonsConsumed = amount/3.785
            }
            ///if the fuel volume unit is set to gallon.
            else if settings.getFuelVolumeUnit == "Gallon" {
                ///set amount as gallon sconsumed annually
                autoSummary.gallonsConsumed = amount
                ///set converted amount as litre consumed annually
                autoSummary.litreConsumed = amount * 3.785
            }
            ///if the fuel volume unit is set to %
            else {
                ///calcuate the kwh from the % of consumption and set it in autosummary prop.
                autoSummary.kwhConsumed = (vehicle.batteryCapacity * amount)/100
            }
            ///get the report index of previous year if available
            if let previousYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year - 1)}) {
                ///set the previousYears odometer end as start of this year's odometer
                autoSummary.odometerStart = reports[previousYearIndex].odometerEnd
                ///set the previousYears odometer end as start of this year's odometer in miles.
                autoSummary.odometerStartMiles = reports[previousYearIndex].odometerEndMiles
            }
            ///get the report index of next year if available
            if let nextYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year + 1)}) {
                ///set the next Year's odometer start as end of this year's odometer.
                autoSummary.odometerEnd = reports[nextYearIndex].odometerStart
                ///set the next Year's odometer start as end of this year's odometer in miles.
                autoSummary.odometerEndMiles = reports[nextYearIndex].odometerStartMiles
            }
            ///add a new report  to vehicle entity.
            vehicle.addToReports(autoSummary)
            ///save the context.
            Vehicle.saveContext(viewContext: viewContext)
        }
    }
    static func createNewReport(viewContext: NSManagedObjectContext, in settings: Settings, for vehicle: Vehicle, year: Int) {
        ///get the reports from the viewcontext
        let reports = getResults(viewContext: viewContext, vehicle: vehicle)
        ///create an autosummary object.
        let autoSummary = AutoSummary(context: viewContext)
        ///set a calendar year to a year of interest.
        autoSummary.calenderYear = Int16(year)
        autoSummary.odometerStart = vehicle.odometer
        autoSummary.odometerEnd = vehicle.odometer
        autoSummary.odometerStartMiles = vehicle.odometerMiles
        autoSummary.odometerEndMiles = vehicle.odometerMiles
        autoSummary.annualTrip = vehicle.trip
        autoSummary.annualTripMiles = vehicle.tripMiles
        autoSummary.annualTripEV = vehicle.tripHybridEV
        autoSummary.annualTripEVMiles = vehicle.tripHybridEVMiles
        ///get the report index of previous year if available
        if let previousYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year - 1)}) {
            ///set the previousYears odometer end as start of this year's odometer
            autoSummary.odometerStart = reports[previousYearIndex].odometerEnd
            ///set the previousYears odometer end as start of this year's odometer in miles.
            autoSummary.odometerStartMiles = reports[previousYearIndex].odometerEndMiles
        }
        ///get the report index of next year if available
        if let nextYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year + 1)}) {
            ///set the next Year's odometer start as end of this year's odometer.
            autoSummary.odometerEnd = reports[nextYearIndex].odometerStart
            ///set the next Year's odometer start as end of this year's odometer in miles.
            autoSummary.odometerEndMiles = reports[nextYearIndex].odometerStartMiles
        }
        ///add a new report  to vehicle entity.
        vehicle.addToReports(autoSummary)
        ///save the context.
        Vehicle.saveContext(viewContext: viewContext)
    }
    
    static func updateReport(viewContext: NSManagedObjectContext, for vehicle: Vehicle, year: Int, odometer: Int, odometerMiles: Int) {
        let reports = getResults(viewContext: viewContext, vehicle: vehicle)
        guard let index = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == year}) else {
            return
        }
        reports[index].odometerEnd = Double(odometer)
        reports[index].odometerEndMiles = Double(odometerMiles)
        ///if the odometer start is greater than odometer end after the change in odometer of a given vehicle
        if reports[index].odometerStart > reports[index].odometerEnd {
            ///set the odometer start value to same as odometer end.
            reports[index].odometerStart = Double(odometer)
        }
        ///if the odometer start is greater than odometer end after the change in odometer of a given vehicle
        if reports[index].odometerStartMiles > reports[index].odometerEndMiles {
            ///set the odometer start value to same as odometer end.
            reports[index].odometerStartMiles = Double(odometerMiles)
        }
        AutoSummary.saveContext(viewContext: viewContext)
    }
    
    ///method to accumulate service cost for a given vehicle in a given year.
    static func accumulateServiceCostSummary(viewContext: NSManagedObjectContext, for vehicle: Vehicle, year: Int, cost: Double) {
        ///get autoSummary reports for a given year.
        let reports = self.getResults(viewContext: viewContext, vehicle: vehicle)
        
        ///get an index of a report corresponding a given vehicle in a given year.
        if let reportIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == year}) {
            ///reset the service costs.
            reports[reportIndex].annualServiceCost = 0
            reports[reportIndex].annualServiceCostEV = 0
            ///iterate through the services array of a given year
            for service in vehicle.getServices.filter({Calendar.current.component(.year, from: $0.date!) == year}) {
                ///accumulate the service costs to annual service cost in the report
                reports[reportIndex].annualServiceCost += service.cost
                ///accumulate the service costs to annual EV service cost in the report
                reports[reportIndex].annualServiceCostEV += service.cost
            }
            ///update the odometer end reading with the latest vehicle odometer readings.
            reports[reportIndex].odometerEnd = vehicle.odometer
            ///update the odometer end reading with the latest vehicle odometer readings in miles.
            reports[reportIndex].odometerEndMiles = vehicle.odometerMiles
            ///save the context.
            Vehicle.saveContext(viewContext: viewContext)
        }
        ///if no reports found in a given year.
        else {
            ///create an autosummary object.
            let autoSummary = AutoSummary(context: viewContext)
            ///set the calendar year to given year.
            autoSummary.calenderYear = Int16(year)
            ///set the annual service cost to the given cost
            autoSummary.annualServiceCost = cost
            autoSummary.annualServiceCostEV = cost
            
            ///get the report index of previous year if available
            if let previousYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year - 1)}) {
                ///set the previousYears odometer end as start of this year's odometer
                autoSummary.odometerStart = reports[previousYearIndex].odometerEnd
                ///set the previousYears odometer end as start of this year's odometer in miles.
                autoSummary.odometerStartMiles = reports[previousYearIndex].odometerEndMiles
            }
            ///get the report index of next year if available
            if let nextYearIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == (year + 1)}) {
                ///set the next Year's odometer start as end of this year's odometer.
                autoSummary.odometerEnd = reports[nextYearIndex].odometerStart
                ///set the next Year's odometer start as end of this year's odometer in miles.
                autoSummary.odometerEndMiles = reports[nextYearIndex].odometerStartMiles
            }
            ///add a new report  to vehicle entity.
            vehicle.addToReports(autoSummary)
            ///save the context.
            AutoSummary.saveContext(viewContext: viewContext)
        }
    }
}

extension AutoSummary : Identifiable {

}
