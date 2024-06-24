//
//  StatsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct AutoStatsView: View {
    let rows = [GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading)]
    @State var showFuelHistoryView = false
    @State var showServiceHistoryView = false
    @State var showFuellingEntryform = false
    @State var showServiceEntryForm = false
    @State var fuelDataHistory: [FuelData] = []
    @State var autoServiceHistory: [AutoService] = []
    @Environment (\.colorScheme) var bgMode: ColorScheme
    @StateObject var locationDataManager: LocationDataManager
    
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var lightRedColor = Color(red:1.0, green:0.654, blue:0.663)
    
    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
    var lightGreenColor = Color(red: 0.723, green: 1.0, blue: 0.856)
    
    var orangeColor = Color(red: 0.975, green: 0.505, blue: 0.076)
    var lightOrangeColor = Color(red: 0.904, green: 0.808, blue: 0.827)
    
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
    
    var yellowColor = Color(red:0.975, green: 0.646, blue: 0.207)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.781)
    
    var purpleColor = Color(red: 0.396, green: 0.381, blue: 0.905)
    var lightPurpleColor = Color(red:0.725,green:0.721, blue:1.0)
    
    let dateFomatter = DateFormatter()
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                List {
                    Section("Dashboard") {
                        LazyHGrid(rows: rows) {
                            DashGridItemView(title: "ODOMETER", foreGroundColor: purpleColor, backGroundColor: lightPurpleColor, numericText: String(format:"%.1f",locationDataManager.odometer), unitText: "km", geometricSize: geo.size)
                            DashGridItemView(title: "FUEL", foreGroundColor: yellowColor, backGroundColor: lightYellowColor, numericText: "37.56", unitText: "litre", geometricSize: geo.size)
                            DashGridItemView(title: "FUEL COST", foreGroundColor: orangeColor, backGroundColor: lightOrangeColor, numericText: "$12,000.23", unitText: "Year 2024", geometricSize: geo.size)
                            DashGridItemView(title: "TRIP", foreGroundColor: skyColor, backGroundColor: lightSkyColor, numericText: locationDataManager.distanceText, unitText: "km", geometricSize: geo.size)
                            DashGridItemView(title: "MILEAGE", foreGroundColor: greenColor, backGroundColor: lightGreenColor, numericText: "12.32", unitText: "km/l", geometricSize: geo.size)
                           
                            DashGridItemView(title: "REPAIR COST", foreGroundColor: redColor    , backGroundColor: lightRedColor, numericText: "$1603.45", unitText: "Year 2024", geometricSize: geo.size)
                        }
                    }
                    .padding(10)
                                  
                    Section {
                        ScrollView {
                            NewEntryStackView(width: geo.size.width)
                            .onTapGesture {
                                showFuellingEntryform.toggle()
                            }
                            .sheet(isPresented: $showFuellingEntryform, content: {
                                FuellingEntryForm(fuelDataHistory: $fuelDataHistory, showFuellingEntryform: $showFuellingEntryform)
                            })
                            ForEach(fuelDataHistory, id:\.self.id) { fuelData in
                                    Group {
                                        VStack {
                                            Text((fuelData.date!.formatted(date: .long, time: .omitted)))
                                                .font(.system(size: 15))
                                                .fontWeight(.black)
                                                .foregroundStyle(redColor)
                                               // .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                Spacer()
                                            HStack {
                                                VStack {
                                                    Text("Fuel Station")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    Text(fuelData.location!)
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(skyColor)
                                                }
                                                .frame(width: 100)
                                               
                                                Spacer()
                                                VStack {
                                                    Text("Fuel")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    Text(String(format:"%.2f",fuelData.amount!) + " L")
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(yellowColor)
                                                   
                                         
                                                }
                                                Spacer()
                                                VStack {
                                                    Text("Cost")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    Text("$" + String(format:"%.2f",fuelData.cost!))
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(greenColor)
                                                }
                                              
                                               
                                            }
                                           Spacer()
                                            
                                            Text("timeStamp: " + fuelData.dateStamp)
                                                .font(.system(size: 8))
                                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        }
                                        .padding(10)
                                            .frame(width:geo.size.width - 30)
                                        Divider()
                                            .padding(.horizontal,20)
                                    }
                                    .onTapGesture {
                                      
                                }
                            }
                        }
                        .frame(width:geo.size.width - 20,height: geo.size.height/1.5)
                        
                    }
                header: {
                        VStack {
                            HStack(spacing: 0) {
                                Text("Fuelling History")
                                Spacer()
                            }
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    showFuelHistoryView.toggle()
                                }, label: {Text("View More").font(.system(size: 12))})
                                .sheet(isPresented: $showFuelHistoryView, content: {
                                    FuelHistoryView()
                                })
                            }
                            
                        }
                    }
    
                    Section {
                        ScrollView {
                            NewEntryStackView(width: geo.size.width)
                            .onTapGesture {
                                showServiceEntryForm.toggle()
                            }
                            .sheet(isPresented: $showServiceEntryForm, content: {
                                ServiceEntryForm(autoServiceHistory: $autoServiceHistory, showServiceEntryForm: $showServiceEntryForm)
                            })
                            ForEach(autoServiceHistory, id: \.self.id) { autoService in
                                    Group {
                                        VStack {
                                            Text(autoService.date!.formatted(date: .long, time: .omitted))
                                                .font(.system(size: 15))
                                                .fontWeight(.black)
                                                .foregroundStyle(redColor)
                                            Spacer()
                                            HStack {
                                                VStack {
                                                    Text("Auto Shop")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    Text(autoService.location!)
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(skyColor)
                                                }
                                               
                                                Spacer()
                                                VStack {
                                                    Text("Cost")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    Text("$" + String(format:"%.2f",autoService.cost!))
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(greenColor)
                                                }
                                           
                                            }
                                           Spacer()
                                            Text("Created at: " + autoService.timeStamp)
                                                .font(.system(size: 8))
                                        }
                                        .padding(10)
                                            .frame(width:geo.size.width - 30)
                                        
                                      
                                        Divider()
                                            .padding(.horizontal,20)
                                    }
                                    .onTapGesture {
                                      
                                    }
                                
                            }
                        }
                        .frame(width:geo.size.width - 20,height: geo.size.height/1.5)
                    }
                header: {
                        VStack {
                            HStack(spacing: 0) {
                                Text("Service History")
                                Spacer()
                            }
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    showServiceHistoryView.toggle()
                                }, label: {Text("View More").font(.system(size: 12))})
                                .sheet(isPresented: $showServiceHistoryView, content: {
                                   ServiceHistoryView()
                                })
                            }
                            
                        }
                    }
                  //  .background(.green)
                }
                .frame(width: geo.size.width, height: geo.size.height - 40)
                .navigationTitle("Auto Summary")
            }
          
           
        }
        
    }
}

#Preview {
    AutoStatsView(locationDataManager: LocationDataManager())
}
