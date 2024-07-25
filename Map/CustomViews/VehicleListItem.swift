//
//  VehicleListItem.swift
//  Map
//
//  Created by saj panchal on 2024-07-25.
//

import SwiftUI

struct VehicleListItem: View {
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    var v: Int
    var body: some View {
        HStack {
            VStack {
                Text(vehicles[v].getVehicleText)
                    .frame(alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(String(vehicles[v].year))
                    .frame(alignment: .leading)
                    .font(.system(size: 14))
                    .fontWeight(.regular)
            }
            Spacer()
            HStack {
                Image(systemName: "car.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                if vehicles[v].getFuelEngine == "Gas" {
                    Image(systemName: "fuelpump.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.yellow)
                }
                else if vehicles[v].getFuelEngine == "EV" {
                    Image(systemName: "bolt.batteryblock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
                else {
                    Image(systemName: "fuelpump.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.yellow)
                    Image(systemName: "bolt.batteryblock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

#Preview {
    VehicleListItem(v: 0)
}
