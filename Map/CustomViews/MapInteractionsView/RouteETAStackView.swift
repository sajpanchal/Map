//
//  DestinationInfoView.swift
//  Map
//
//  Created by saj panchal on 2024-06-08.
//

import SwiftUI

struct RouteETAStackView: View {
    ///bounded property to show or hide the footer expanded view
    @Binding var showAddressView: Bool
    ///this variable is going to store the address and name of the destination location.
    var destination: String
    @Binding var ETA: String
    @State var height = 200.0
    @Binding var addressViewHeight: CGFloat
    ///variable that stores and displayes the distance remaining from the current location to destination
    var remainingDistance: String
    
    var body: some View {
        ///enclose the ETA texts in HStack
        HStack {
            ///add as spacer on left side of the hstack
            Spacer()
            ///enclose the remaining Distance text with its subtitle in VStack.
            VStack {
                Text(remainingDistance)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(Color(AppColors.invertRed.rawValue))
                Text("Remains")
                    .foregroundStyle(.gray)
            }
            ///add a spacer after the vstack
            Spacer()
            ///enclose the ETA text with its subtitle in VStack
            VStack {
                Text(ETA)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(Color(AppColors.invertGreen.rawValue))
                Text("Arrival")
                    .foregroundStyle(.gray)
            }
            ///add a spacer after the vstack
            Spacer()
        }
        .gesture(
            DragGesture()
            .onChanged(dragGestureChanged)
            .onEnded(dragGestureChanged)
        )
    }
    func dragGestureChanged(value: DragGesture.Value) {
        withAnimation {
            if value.translation.height < 0  && abs(value.translation.height) > 10 {
                showAddressView = true
                addressViewHeight = min(80, abs(value.translation.height))
            }
            else if value.translation.height >= 0 && abs(value.translation.height) > 10 {
                addressViewHeight = abs(value.translation.height) <= 80 ?  80 - value.translation.height : 0
                if addressViewHeight <= 5 {
                    showAddressView = false
                }
            }
        }
    }
}

#Preview {
    RouteETAStackView(showAddressView: .constant(false), destination: "", ETA: .constant(""), addressViewHeight: .constant(0.0), remainingDistance: "")
}
