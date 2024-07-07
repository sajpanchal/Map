//
//  Enums.swift
//  Map
//
//  Created by saj panchal on 2023-08-25.
//

import Foundation

//enum type to be used to track the status of MapView
enum MapViewStatus {
    case navigating, centeredToUserLocation, inNavigationCentered, showingDirections, notCentered, inNavigationNotCentered, idle, showingDirectionsNotCentered
}
//enum type to be used to track the button actions of MapView
enum MapViewAction {
    case navigate, centerToUserLocation, inNavigationCenterToUserLocation, showDirections, idle, idleInNavigation, idleInshowDirections
}
//enumeration type definition to handle error. it is of string type so we can assign associated values to each enum case as strings.
enum Errors: String {
    case locationNotFound = "Sorry, your current location not found!"
    case headingNotFound = "Sorry, your current heading not found!"
    case locationNotVisible = "Sorry, your current location is not able to display on map!"
    case unKnownError = "Sorry, unknown error has occured!"
    case noError = " -- "
}

enum LocalSearchStatus {
    case locationSelected
    case localSearchInProgress
    case localSearchCancelled
    case localSearchResultsAppear
    case showingNearbyLocations
    case searchBarActive
}
enum VehicleTypes: String, CaseIterable, Identifiable {
    case Car
    case SUV
    case Truck
    case MotorCycle
    case RV
    case ATV
    var id: Self {
        self
    }
}
enum Model: String, CaseIterable, Identifiable {
    case _428,Ace, Aceca, Cobra, Sport
    case Beaumount
    case CL, CSX, EL, ILX, Integra, Legend, MDX, NSX, RDX, RL, RLX, RSX, TL, TLX, TSX, ZDX
    case Arnage, Azure, Bentayga, Brooklands, Continental, Continental_Flying_Spur, Continental_GT, Continental_GT_Speed, Continental_GT3, Continental_GTC, Continental_GTC_Speed, Continental_Supersports, Eight, Flying_Spur, Mulsanne
    case _1Series, _1600, _2Series, _2002, _3Series, _3_0 = "3.0", _4Series, _428XI, _5Series, _6Series, _7Series, _8Series, Alpina_B10, i3, i4, i5, i7, i8, Isetta, iX, M, M2, M240i, M240i_xDrive, M3, M340i_xDrive, M4, M440i_xDrive, M5, M550i, M6, M8, X1, X2,X3, X3_M, X4, X4_M, X5, X5_M, X6, X6_M, X7, XM, Z3, Z3_M, Z4, Z4_M, Z8
    case Allante, ATS, ATS_V, Brougham, Calais, Catera, Coupe_Deville, CT4, CT4_V, CT5, CT5_V, CT6, CT6_V, CTS, CTS_V, DeVille, DTS, Eldorado, ELR, Escalade, Escalade_ESV, Escalade_EXT, Escalade_EXV, Fleetwood, LaSalle, LYRIQ, Seville, SRX, STS, STS_V, XLR, XLR_V, XT4, XT5, XT6, XTS, Other
    case _200, _200S, _300, Aspen, Cirrus, Crossfire, Daytona, Grand_Caravan, Imperial, Intrepid, LeBaron, New_Yorker, Newport, Pacifica, Pacifica_Hybrid, Prowler, PT_Cruiser, Sebring, TC, Town_N_Country, Voyager, Windsor
    case _12_Ton = "1/2 Ton", _1300, _150, _1500_Pickup, _20_Pickup, _210, _2500_Cab_Chassis, _2500_Pickup, _30_Pickup, _3100_Pickup, _3500_Pickup, _3500_Pickups, _3600, Aero, Apache, Astro, Avalanche, Aveo, Bel_Air, Biscayne, Blazer, Blazer_EV, Bolt_EUV, Bolt_EV, C10, Cab_And_Chassis, Camaro, Caprice, Captiva, Cavalier, Chevelle, Chevette, Chevy, Chevy_II, Chevy_Van, Cheyenne, City_Express, Cobalt, Colorado, Corvair, Corvette, Cruze, Delray, El_Camino, Equinox, Equinox_EV, Express, Express_1500, Express_2500, Express_3500, Express_4500, Express_Passenger, FA_Master, Fleetline, Fleetmaster, G_Series_Van, HHR, Impala, Lumina, Malibu, Malibu_Hybrid, Malibu_Maxx, Master, Master_85, Monte_Carlo, Nomad, Nova, Optra, Orlando, P30, Pickup, S10_Blazer, Silverado, Silverado_1500, Silverado_1500_LTD, Silverado_2500HD, Silverado_3500, Silverado_3500HD, Silverado_3500HD_CC, Silverado_EV, Sonic, Spark, Spark_EV, Special, SS, SSR_Pickup, Styleline, Stylemaster, Suburban, Superior, Tahoe, Tahoe_Hybrid, TrailBlazer ,Traverse, Traverse_Limited, Trax, Uplander, Vega, Venture, Volt
    case Copen, Hijet, Hijet_Truck
    case _024, _12_Ton_Trucks = "1/2 Ton Trucks", _100, _250, _2500, _350, _3500, _440, _600, Avenger, Caliber, Caravan, Caravan_CV, Challenger, Charger, Coronet, Custom_880, Dakota, Dart, Demon, Diplomat, Durango, Dynasty, Fargo, Hornet, Hornet_PHEV, Intrepit, Journey, Magnum, Mayfair, Monaco, Neon, Neon_SRT4, Nitro, Polara, Power_Ram, Raider, RAM, RAM_1500_Pickup, RAM_2500_Pickup, RAM_3500_Pickup, RAM_5500_Cab_Chassis, RAM_Van, Ramcharger, Shadow, Sprinter, Sprinter_2500, Sprinter_3500, SRT_10, Stealth, Super_Bee, SX_20 = "SX 2.0", Viper, W_Series_Pickup
    case Talon
    case Civic, Civic_Coupe, Civic_del_Sol, Civic_Hatchback,Civic_Sedan, Civic_Sedan_EX,Civic_Sedan_LX, Civic_Type_R
    case Phaeton, Roadster
    var id: Self {
        self
    }
    
  
}
enum VehicleMake: String, CaseIterable, Identifiable {

    case AC, Acadian, Acura
   
    case Bentley
    case BMW
    case Cadillac
    case Chevrolet
    case Chrysler
    case Daihatsu
    case Dailmler
    case Dodge
    case Eagle
    case Honda
    case Excalibur
//    case Farrari
//    case Fiat
    var models: [Model] {
        switch self {
        case .AC:
            return [._428,.Ace, .Aceca, .Cobra, .Sport, .Other]
        case .Acadian:
            return [.Beaumount, .Other]
        case .Acura:
            return [.CL, .CSX, .EL, .ILX, .Integra, .Legend, .MDX, .NSX, .RDX,.RL, .RLX, .RSX, .TL, .TLX, .TSX, .ZDX, .Other]
        case .Bentley:
            return [.Arnage, .Azure,.Bentayga,.Brooklands, .Continental, .Continental_Flying_Spur, .Continental_GT, .Continental_GT_Speed, .Continental_GT3, .Continental_GTC, .Continental_GTC_Speed, .Continental_Supersports, .Eight, .Flying_Spur, .Mulsanne, .Other]
        case .BMW:
            return [._1Series, ._1600, ._2Series, ._2002, ._3Series, ._3_0, ._4Series, ._428XI, ._5Series, ._6Series, ._7Series, ._8Series, .Alpina_B10, .i3, .i4, .i5, .i7, .i8, .Isetta, .iX, .M, .M2, .M240i, .M240i_xDrive, .M3, .M340i_xDrive, .M4, .M440i_xDrive, .M5, .M550i, .M6, .M8, .X1, .X2, .X3, .X3_M, .X4, .X4_M, .X5, .X5_M, .X6, .X6_M, .X7, .XM, .Z3, .Z3_M, .Z4, .Z4_M, .Z8, .Other]
        case .Cadillac:
            return [.Allante, .ATS, .ATS_V, .Brougham, .Calais, .Catera, .Coupe_Deville, .CT4, .CT4_V, .CT5, .CT5_V, .CT6, .CT6_V, .CTS, .CTS_V, .DeVille, .DTS, .Eldorado, .ELR, .Escalade, .Escalade_ESV, .Escalade_EXT, .Escalade_EXV, .Fleetwood, .LaSalle, .LYRIQ, .Seville, .SRX, .STS, .STS_V, .XLR, .XLR_V, .XT4, .XT5, .XT6, .XTS, .Other]
        case .Chrysler:
            return [._200, ._200S, ._300, .Aspen, .Cirrus, .Crossfire, .Daytona, .Grand_Caravan, .Imperial, .Intrepid, .LeBaron, .New_Yorker, .Newport, .Pacifica, .Pacifica_Hybrid, .Prowler, .PT_Cruiser, .Sebring, .TC, .Town_N_Country, .Voyager, .Windsor, .Other]
        case .Chevrolet:
            return [._12_Ton, ._1300, ._150, ._1500_Pickup, ._20_Pickup, ._210, ._2500_Cab_Chassis, ._2500_Pickup, ._30_Pickup, ._3100_Pickup, ._3500_Pickup, ._3500_Pickups, ._3600, .Aero, .Apache, .Astro, .Avalanche, .Aveo, .Bel_Air, .Biscayne, .Blazer, .Blazer_EV, .Bolt_EUV, .Bolt_EV, .C10, .Cab_And_Chassis, .Camaro, .Caprice, .Captiva, .Cavalier, .Chevelle, .Chevette, .Chevy, .Chevy_II, .Chevy_Van, .Cheyenne, .City_Express, .Cobalt, .Colorado, .Corvair, .Corvette, .Cruze, .Delray, .El_Camino, .Equinox, .Equinox_EV, .Express, .Express_1500, .Express_2500, .Express_3500, .Express_4500, .Express_Passenger, .FA_Master, .Fleetline, .Fleetmaster, .G_Series_Van, .HHR, .Impala, .Lumina, .Malibu, .Malibu_Hybrid, .Malibu_Maxx, .Master, .Master_85, .Monte_Carlo, .Nomad, .Nova, .Optra, .Orlando, .P30, .Pickup, .S10_Blazer, .Silverado, .Silverado_1500, .Silverado_1500_LTD, .Silverado_2500HD, .Silverado_3500, .Silverado_3500HD, .Silverado_3500HD_CC, .Silverado_EV, .Sonic, .Spark, .Spark_EV, .Special, .SS, .SSR_Pickup, .Styleline, .Stylemaster, .Suburban, .Superior, .Tahoe, .Tahoe_Hybrid, .TrailBlazer , .Traverse, .Traverse_Limited, .Trax, .Uplander, .Vega, .Venture, .Volt, .Other]
        case .Dailmler:
            return [.Copen, .Hijet, .Hijet_Truck, .Other]
        case .Daihatsu:
            return [.Other]
        case .Dodge:
            return [._024, ._12_Ton_Trucks, ._100, ._150, ._250, ._2500, ._350, ._3500, ._440, ._600, .Avenger, .Caliber, .Caravan, .Caravan_CV, .Challenger, .Charger, .Coronet, .Custom_880, .Dakota, .Dart, .Demon, .Diplomat, .Durango, .Dynasty, .Fargo, .Grand_Caravan, .Hornet, .Hornet_PHEV, .Intrepit, .Journey, .Magnum, .Mayfair, .Monaco, .Neon, .Neon_SRT4, .Nitro, .Polara, .Power_Ram, .Raider, .RAM, .RAM_1500_Pickup, .RAM_2500_Pickup, .RAM_3500_Pickup, .RAM_5500_Cab_Chassis, .RAM_Van, .Ramcharger, .Shadow, .Sprinter, .Sprinter_2500, .Sprinter_3500, .SRT_10, .Stealth, .Super_Bee, .SX_20, .Viper, .W_Series_Pickup,.Other]
        case .Eagle:
            return [.Talon, .Other]
        case .Honda:
            return[.Civic, .Civic_Coupe, .Civic_del_Sol, .Civic_Hatchback, .Civic_Sedan, .Civic_Sedan_EX, .Civic_Sedan_LX, .Civic_Type_R, .Other]
       case .Excalibur:
            return [.Phaeton, .Roadster, .Other]
//        case .Farrari:
//            return [("250", UUID()), ("275", UUID())]
//        case .Fiat:
//            return [("124", UUID()), ("Spider", UUID())]
        }
    }
    var id: Self {
        self
    }
}
enum Alphbets: String, CaseIterable, Identifiable {
    case A,B,C,D,E/*,F,G*/,H//,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
 
    var makes: [VehicleMake] {
        switch self {
        case .A:
            return [.AC, .Acadian, .Acura]
        case .B:
            return [.Bentley, .BMW]
        case .C:
            return [.Cadillac, .Chevrolet, .Chrysler]
        case .D:
            return [.Daihatsu, .Dailmler, .Dodge]
        case .E:
            return [.Eagle, .Excalibur]
//        case .F:
//            return[.Farrari, .Fiat]
        case .H:
            return[.Honda]
        }
    }
    var id: Self {
        self
    }
}

enum FuelTypes: String, CaseIterable, Identifiable  {
    case Gas
    case EV
    case Hybrid
    var id: Self {
        self
    }
}

enum DistanceModes: String, CaseIterable, Identifiable  {
    case km
    case miles
    var id: Self {
        self
    }
}
enum FuelModes: String, CaseIterable, Identifiable  {
    case Litre
    case Gallon
    var id: Self {
        self
    }
}
enum EfficiencyModesL: String, CaseIterable, Identifiable  {
    case kmpl = "km/L"
    case mpl = "miles/L"

    
    var id: Self {
        self
    }
}
enum EfficiencyModesL2: String, CaseIterable, Identifiable  {
  
    case lp100km = "L/100km"
    case lp100m = "L/100miles"
    
    var id: Self {
        self
    }
}

enum EfficiencyModesG: String, CaseIterable, Identifiable  {
    case kmpg = "km/gl"
    case mpg = "miles/gl"
    case gp100km = "gl/100km"
    case gp100m = "gl/100miles"
    var id: Self {
        self
    }
}
enum EfficiencyModesG2: String, CaseIterable, Identifiable  {
    
    case gp100km = "gl/100km"
    case gp100m = "gl/100miles"
    var id: Self {
        self
    }
}
