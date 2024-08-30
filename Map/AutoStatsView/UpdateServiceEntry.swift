//
//  UpdateServiceEntry.swift
//  Map
//
//  Created by saj panchal on 2024-07-28.
//

import SwiftUI

struct UpdateServiceEntry: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoService.entity(), sortDescriptors: []) var serviceEntries: FetchedResults<AutoService>
    @State var location: String = ""
    @State var type: ServiceTypes = .service
    @State var description: String = ""
    @State var cost: String = ""
    @State var date: Date = Date()
    @State var isButtonTapped = false
    var serviceEntry: AutoService
    enum ServiceTypes: String, CaseIterable, Identifiable {
        case service, repair, bodyWork, wash
        var id: Self {
            self
        }
    }
    
    var body: some View {
        NavigationStack {
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
                    TextField("Enter total cost", text: $cost)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isButtonTapped = false
                        }
                    if cost.isEmpty && isButtonTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(cost) == nil && isButtonTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Section(header: Text("Date of Service") .fontWeight(.bold)) {
                    DatePicker("Set Date", selection: $date, displayedComponents: [.date])
                    if date > Date() {
                        Text("Future date is not acceptable!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                if let vehicle = vehicles.first(where: {$0.isActive}) {
                    VStack {
                        Button {
                            if isTextFieldEntryValid() {
                                if let index = serviceEntries.firstIndex(where: {$0.vehicle == vehicle && $0.uniqueID == serviceEntry.uniqueID}) {
                                    editServiceCost(at: index)
                                }
                                aggregateServiceCost(for: vehicle)
                            }
                            isButtonTapped = true
                       
                        } label: {
                            FormButton(imageName: "plus.square.fill", text: "Add Entry", color: Color(AppColors.red.rawValue))
                        }
                        .background(Color(AppColors.invertRed.rawValue))
                        .buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(100)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }                
            }
            .navigationTitle("Add Auto Service")
        }
        .onAppear(perform: {
            location = serviceEntry.location ?? ""
            type = ServiceTypes(rawValue: serviceEntry.type!) ?? .service
            description = serviceEntry.details ?? ""
            cost = String(serviceEntry.cost)
            date = serviceEntry.date ?? Date()
            
        })
    }
    
    func editServiceCost(at index: Int) {
        serviceEntries[index].cost = Double(cost) ?? 0
        serviceEntries[index].details = description
        serviceEntries[index].location = location
        serviceEntries[index].type = type.rawValue.capitalized
        serviceEntries[index].date = date
        serviceEntries[index].timeStamp = Date()
        Vehicle.saveContext(viewContext: viewContext)
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
    
    func isTextFieldEntryValid() -> Bool {
        if location.isEmpty || cost.isEmpty {
            return false
        }
        if Double(location) != nil || Double(cost) == nil {
            return false
        }
        if date > Date() {
            return false
        }
        return true
    }
}

#Preview {
    UpdateServiceEntry(serviceEntry: AutoService())
}
