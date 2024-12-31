//
//  ServiceEntryForm.swift
//  Map
//
//  Created by saj panchal on 2024-06-24.
//

import SwiftUI

struct ServiceEntryForm: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    @State private var location: String = ""
    @State private var type: ServiceTypes = .service
    @State private var description: String = ""
    @State private var cost = 0.0
    @State private var date: Date = Date()
    @State private var isButtonTapped = false
    @Binding var showServiceEntryForm: Bool
    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Form {
                        Section(header:Text("Shop Name").fontWeight(.bold)) {
                            TextField("Enter name of the location", text: $location)
                                .onTapGesture {
                                    isButtonTapped = false
                                }
                               
                            if location.isEmpty && isButtonTapped {
                                Text("location field can not be empty!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                            else if Double(location) != nil && isButtonTapped {
                                Text("Please enter the valid text entry!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                            
                        }
                        Section(header:Text("Service Type").fontWeight(.bold)) {
                            Picker("Select type", selection: $type) {
                                ForEach(ServiceTypes.allCases) { service in
                                    Text(service.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.palette)
                        }
                        Section(header: Text("Description").fontWeight(.bold)) {
                            TextEditor(text: $description)
                                .font(Font.system(size:14))
                                .frame(height: 70)
                        }
                        Section(header:Text("Cost").fontWeight(.bold)) {
                            TextField("Enter total cost", value: $cost, format: .number)
                                .keyboardType(.decimalPad)
                                .onTapGesture {
                                    isButtonTapped = false
                                }
                            if cost == 0 && isButtonTapped {
                                Text("This field can not be empty!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                            else if cost < 0 && isButtonTapped {
                                Text("Please enter the valid text entry!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        Section(header: Text("Date of Service").fontWeight(.bold)) {
                            DatePicker("Set Date", selection: $date, displayedComponents: [.date])
                            if date > Date() {
                                Text("Future date is not acceptable!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        if let vehicle = vehicles.first(where: {$0.isActive}) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        if isTextFieldEntryValid() {
                                            let service = AutoService(context: viewContext)
                                            addServiceEntry(service: service)
                                            vehicle.addToServices(service)
                                            aggregateServiceCost(for: vehicle)
                                            updateAutoSummary(for: vehicle)
                                        }
                                    isButtonTapped = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showServiceEntryForm = !isTextFieldEntryValid()
                                        }
                                    } label: {
                                        FormButton(imageName: "plus.square.fill", text: "Add Entry", color: Color(AppColors.red.rawValue))
                                    }
                                    .background(Color(AppColors.invertRed.rawValue))
                                    .buttonStyle(BorderlessButtonStyle())
                                    .cornerRadius(100)
                                    .shadow(color: bgMode == .dark ? .gray : .black, radius: 1, x: 1, y: 1)
                                    Spacer()
                                }
                              
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                if showAlert {
                    AlertView(image: "wrench.and.screwdriver.fill", headline: "Service Entry Added!", bgcolor: Color(AppColors.invertRed.rawValue), showAlert: $showAlert)
                }
            }
          
            .navigationTitle("Add Auto Service")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func addServiceEntry(service: AutoService) {
        service.uniqueID = UUID()
        service.cost = cost
        service.details = description
        service.location = location
        service.type = type.rawValue.capitalized
        service.date = date
        service.timeStamp = Date()
        Vehicle.saveContext(viewContext: viewContext)
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
    }
    
    func aggregateServiceCost(for vehicle: Vehicle) {
        if  let i = vehicles.firstIndex(where: {$0.uniqueID == vehicle.uniqueID}) {
            vehicles[i].serviceCost = 0
            for service in vehicle.getServices {
                vehicles[i].serviceCost += service.cost
        }
            Vehicle.saveContext(viewContext: viewContext)
        }
    }
    
    func updateAutoSummary(for vehicle: Vehicle) {
        let year = Calendar.current.component(.year, from: date)
        if let i = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == year}) {
          
            reports[i].annualServiceCost = 0
            reports[i].annualServiceCostEV = 0
            for service in vehicle.getServices.filter({Calendar.current.component(.year, from: $0.date!) == year}) {
             
                reports[i].annualServiceCost += service.cost
                reports[i].annualServiceCostEV += service.cost
            }
            reports[i].odometerEnd = vehicle.odometer
            reports[i].odometerEndMiles = vehicle.odometerMiles
            Vehicle.saveContext(viewContext: viewContext)
        }
        else {
            print("Record not found for year \(year)")
            if let i = vehicles.firstIndex(where: {$0.uniqueID == vehicle.uniqueID}) {
                let autoSummary = AutoSummary(context: viewContext)
                autoSummary.calenderYear = Int16(year)
                autoSummary.annualServiceCost = cost
                autoSummary.annualServiceCostEV = cost
                autoSummary.odometerEnd = vehicles[i].odometer
                autoSummary.odometerEndMiles = vehicles[i].odometerMiles
                vehicles[i].addToReports(autoSummary)
                AutoSummary.saveContext(viewContext: viewContext)
                print("new service entry saved")
            }
        }
    }
    
    func isTextFieldEntryValid() -> Bool {
        if location.isEmpty || cost == 0 {
            return false
        }
        if Double(location) != nil || cost < 0 {
            return false
        }
        if date > Date() {
            return false
        }
        return true
    }
}

#Preview {
    ServiceEntryForm(showServiceEntryForm: .constant(false))
}
