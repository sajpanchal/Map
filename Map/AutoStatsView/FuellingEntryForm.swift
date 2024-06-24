//
//  FuellingEntryForm.swift
//  Map
//
//  Created by saj panchal on 2024-06-22.
//

import SwiftUI

struct FuellingEntryForm: View {
    @Binding var fuelDataHistory: [FuelData]
    @State var location = ""
    @State var amount = ""
    @State var cost = ""
    @State var date: Date = Date()
    @Binding var showFuellingEntryform: Bool
    @State var isTapped = false
    var yellowColor = Color(red:0.975, green: 0.646, blue: 0.207)
    //var lightYellowColor = Color(red:0.975, green: 0.918, blue: 0.647)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.781)
    var body: some View {
        NavigationStack {
            Form {
                Section(header:Text("Fuel Station:").font(Font.system(size: 15))) {
                    TextField("Enter Location", text:$location)
                        .onTapGesture {
                            isTapped = false
                        }
                       
                    if location.isEmpty && isTapped {
                        Text("location field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(location) != nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
              
                Section(header:Text("Fuel Volume in Litre:").font(Font.system(size: 15))) {
                    TextField("Enter Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isTapped = false
                        }
                    if amount.isEmpty && isTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(amount) == nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Section(header:Text("Fuel Cost:").font(Font.system(size: 15))) {
                    TextField("Enter Cost", text: $cost)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isTapped = false
                        }
                    if cost.isEmpty && isTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(cost) == nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Section(header: Text("Date:").font(Font.system(size: 15))) {
                    DatePicker("Fuelling Day", selection: $date, displayedComponents:[.date])
                      
                    if date > Date() {
                        Text("Future date is not acceptable!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                VStack {
                    Button {
                        if isTextFieldEntryValid() {
                            if fuelDataHistory.isEmpty {
                                fuelDataHistory.insert(FuelData(location: location, amount: Double(amount), cost: Double(cost), date: date), at: 0)
                            }
                            else {
                                fuelDataHistory.append(FuelData(location: location, amount: Double(amount), cost: Double(cost), date: date))
                            }
                            print(DateFormatter().string(from: date))
                        }
                       
                        isTapped = true
                      
                     showFuellingEntryform = !isTextFieldEntryValid()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.square.fill")
                                .foregroundStyle(lightYellowColor)
                                .font(Font.system(size: 25))
                            
                            Text("Add Entry")
                              
                                .foregroundStyle(lightYellowColor)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(yellowColor)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                      
            }
            .navigationTitle("Add Fuelling Entry")
    
           
        }
       
    }
    func isTextFieldEntryValid() -> Bool {
        if location.isEmpty || amount.isEmpty || cost.isEmpty {
            return false
        }
        if Double(amount) == nil || Double(cost) == nil || Double(location) != nil {
            return false
        }
        if date > Date() {
            return false
        }
        
        return true
    }
    
}


#Preview {
    FuellingEntryForm(fuelDataHistory: .constant([]), showFuellingEntryform: .constant(false))
}
