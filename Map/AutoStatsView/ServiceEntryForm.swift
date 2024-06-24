//
//  ServiceEntryForm.swift
//  Map
//
//  Created by saj panchal on 2024-06-24.
//

import SwiftUI

struct ServiceEntryForm: View {
    @Binding var autoServiceHistory: [AutoService]
    @State var location: String = ""
    @State var type: ServiceTypes = .service
    @State var description: String = ""
    @State var cost: String = ""
    @State var date: Date = Date()
    @State var isButtonTapped = false
    @Binding var showServiceEntryForm: Bool
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var lightRedColor = Color(red:1.0, green:0.654, blue:0.663)
    enum ServiceTypes: String, CaseIterable, Identifiable {
        case service, repair, bodyWork, wash
        var id: Self {
            self
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Section(header:Text("Auto Shop Location:").font(Font.system(size: 15))) {
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
                Section(header:Text("Auto Service Type:").font(Font.system(size: 15))) {
                    Picker("Select type", selection: $type) {
                        ForEach(ServiceTypes.allCases) { service in
                            Text(service.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.palette)
                }
                Section(header: Text("Auto Service Description:").font(Font.system(size: 15))) {
                    TextEditor(text: $description)
                        .font(Font.system(size:14))
                        .frame(height: 70)
                }
                Section(header:Text("Auto Service Cost:").font(Font.system(size: 15))) {
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
                Section(header: Text("Date of Auto Service:").font(Font.system(size: 15))) {
                    DatePicker("Set Date", selection: $date, displayedComponents: [.date])
                    if date > Date() {
                        Text("Future date is not acceptable!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                VStack {
                    Button {
                        if isTextFieldEntryValid() {
                            if autoServiceHistory.isEmpty {
                                autoServiceHistory.insert(AutoService(location: location, type: type.rawValue.capitalized, description:description, cost: Double(cost), date: date), at: 0)
                            }
                            else {
                                autoServiceHistory.append(AutoService(location: location, type: type.rawValue.capitalized, description:description, cost: Double(cost), date: date))
                            }
                        }
                        isButtonTapped = true
                      
                     showServiceEntryForm = !isTextFieldEntryValid()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.square.fill")
                                .foregroundStyle(lightRedColor)
                                .font(Font.system(size: 25))
                            
                            Text("Add Entry")
                            
                                .foregroundStyle(lightRedColor)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(redColor)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                    
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
            }
            .navigationTitle("Add Auto Service")
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
    ServiceEntryForm(autoServiceHistory: .constant([]), showServiceEntryForm: .constant(false))
}
