//
//  FuelHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct FuelHistoryView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("2024") {
                    ForEach(0..<5) { i in
                            Group {
                                VStack {
                                    HStack {
                                        Text("Day \(i)")
                                        Spacer()
                                        Text("$\(i).00")
                                    }
                                   
                                    Text("\(Date())")
                                        .font(.system(size: 10))
                                }
                                .padding(10)
                              
                                
                              
                               
                            }
                            .onTapGesture {
                                print("\(i) tapped")
                        }
              
                    
               
                    }
                }
                Section("2023") {
                    ForEach(0..<5) { i in
                            Group {
                                VStack {
                                    HStack {
                                        Text("Day \(i)")
                                        Spacer()
                                        Text("$\(i).00")
                                    }
                                   
                                    Text("\(Date())")
                                        .font(.system(size: 10))
                                }
                                .padding(10)
                              
                                
                              
                               
                            }
                            .onTapGesture {
                                print("\(i) tapped")
                        }
              
                    
               
                    }
                }
              
            }
            .navigationTitle("Fuelling History")
        }
      
    }
}

#Preview {
    FuelHistoryView()
}
