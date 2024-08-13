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
enum ServiceTypes: String, CaseIterable, Identifiable {
    case service, repair, bodyWork, wash
    var id: Self {
        self
    }
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
    case _101, _105, _147, _155, _156, _159, _164, _1750, _4C_Coupe, _4C_Spider, Giulia, Giulia_Quadrifoglio, GTV6, Milano, Spider, Stelvio, Tonale, Tonale_PHEV
    case J2R, K1
    case Speed25, TA14, TB14
    case Hummer
    case Ambassador, Eagle, Gremlin, Javelin, Marlin, Matador, Rambler
    case _770
    case Atom
    case DB11, DB12, DB5, DB7, DB7_Vantage, DB9, DBS, DBS_Superleggera, DBX, DBX707, Rapide, V12_Vantage, V8_Vantage, V8_Vantage_S, Vanquish, Vanquish_S, Vantage, Virage
    case GT
    case  _100_Series, _4000, _5000, _A3, _A3_Sportback, A4, A5, A6, A7, A8, Allroad, Cabriolet, e_tron, e_tron_GT, e_tron_S_Sportback, e_tron_Sportback, Q3, Q4_e_tron, Q4_e_tron_Sportback, Q5, Q7, Q8, Q8_e_tron_Sportback, Quattro, R8, RS_3, RS_4, RS_5, RS_6, RS_7, RS_e_tron_GT, RS_Q8, S3, S4, S5, S6, S7, S8, SQ5, SQ7, SQ8, SQ8_e_tron, SQ8_e_tron_Sportback, TT, TT_RS, TTS, V8
    case GRX
    case A90, Mini
    case _100S, _3000, _3000_MK_I, _3000_MK_II, _3000_MK_III, Sprite
    case V6_Convertible, V8_Coupe
    case Zevo_400, Zevo_600
    case Chiron
    case Allure, Cascada, Century, Electra, Enclave, Encore, Encore_GX, Envision, Envista, Gran_Sport, Grand_National, GSX_Gran_Sport, LaCrosse, LeSabre, Lucerne, Rainier, Reatta, Regal, Rendezvous, Riviera, Roadmaster, Skylark, Super, Verano, Wildcat
    case Super_7
    case _2CV, C6, CX
    case _812
    case  _240Z, _280_ZX, _280_Z
    case Adventurer, Custom
    case Pantera
    case _206
    case Pacer
    case MK4_Roadster
    case pickup
    case _275, _296_GTB, _296_GTS, _328, _348, _355_F1, _355_Spider, _360, _360_Challenge_Stradale, _365_GT, _456, _458, _458_Italia, _458_Spider, _488, _488_GTB, _488_Pista, _488_Pista_Spider, _488_Spider, _512, _550, _575, _575M_Maranello, _599, _612, _812_GTS, _812_Superfast, _California, _California_T, F12_belinetta, _F12_TDF, F355, F430, F430_Spider, F512M, F8_Spider, F8_Triduto, FF, GTC4_Lusso, Mondial, Portfino, Portfino_M, Roma, SF90_Spider, SF90_Stradale, Testarossa
    case _124, _124_Spider, _500, _500_Abarth, _500E, _500L, _500X, _850, Coupe, X1_9
    case Karma, Ocean
    case _1_Ton_Trucks, _3_Ton_Trucks, _4_Ton_Trucks, Anglia, Aspire, Bronco, Bronco_4WD, Bronco_Sport, C_Max, C_Max_Energi, Contour, Country_Squire, Courier_Pickup, Crestline, Crown_Victoria, Crown_Victoria_Police_PKG, Custom_500, Customline, Deluxe, E_150, E_250, E_350, E_450, E_Series, E_Series_Cargo_Van, E_Series_Cutaway, E_Series_Cutaway_Chassis, E_Transit_Chassis, E_Transit_Cutaway, Econoline, EcoSport, Edge, Escape, Excursion, EXP, Expedition, Explorer, Explorer_Sport_Trac, F_1, F_100, F_150, F_150_Lightning, F_250, F_250_HD_Series, F_250_HD_Series_Crew_Cab, F_250_Series_Crew_Cab, F_250_Series_Standard, F_350, F_350_Series, F_450, F_550, F_600, F_650, F_750, F_Series_Pickup, F_Super_Duty_Trucks, Fairlane, Fairmont_Futura, Falcon, Festiva, Fiesta, Five_Hundred, Flex, Focus, Focus_Electric, Freestar, Freestyle, Fusion, Fusion_Energi, Fusion_Hybrid, Fusion_Plug_In_Hybrid, Galaxie, Gran_Torino, LCF, Maverick, Meteor, Model_A, Model_AA, Model_T, Model_TT, Mustang, Mustang_Mach_E, Polic_Interceptor_Sedan, Polic_Interceptor_Utility, Ranchero, Ranger, Sedan, Super_Deluxe, Super_Duty_E450_DRW, Super_Duty_F600_DRW, Super_Duty_F750, Taurus, Taurus_Polic_PKG, TaurusX, Thunderbird, Torino, Transit, Transit_Cargo_Van, Transit_Connect, Transit_Connect_Cargo_Van, Transit_Crew_Van, Transit_Passanger_Wagon
    var id: Self {
        self
    }
    
  
}
enum VehicleMake: String, CaseIterable, Identifiable {

    case AC, Acadian, Acura, Alfa_Romeo, Allard, Alvis, AM_General, American_Bantam, American_Motors_AMC, Amphicar, Ariel, Aston_Martin, Asuna, Audi, Aurora, Austin, Austin_Healey, Avanti_II
   
    case Bentley, BMW, Bradley, BrightDrop, Bugatti, Buick
    case Cadillac, Caterham, Chevrolet, Chrysler, Citroen, Cord
    case Daihatsu, Dailmler, Datsun, De_Soto, De_Tomaso, Divco, Dodge
    case Eagle, Edsel, Excalibur
    case Factory_Five_Racing, Fargo, Farrari, Fiat, Fisker, Ford
    case Honda
 
    
    var models: [Model] {
        switch self {
        case .AC:
            return [._428,.Ace, .Aceca, .Cobra, .Sport, .Other]
        case .Acadian:
            return [.Beaumount, .Other]
        case .Acura:
            return [.CL, .CSX, .EL, .ILX, .Integra, .Legend, .MDX, .NSX, .RDX,.RL, .RLX, .RSX, .TL, .TLX, .TSX, .ZDX, .Other]
        case .Alfa_Romeo:
            return [._101, ._105, ._147, ._155, ._156, ._159, ._164, ._1750, ._4C_Coupe, ._4C_Spider, .Giulia, .Giulia_Quadrifoglio, .GTV6, .Milano, .Spider, .Stelvio, .Tonale, .Tonale_PHEV, .Other]
        case .Allard:
            return [.J2R, .K1, .Other]
        case .Alvis:
            return [.Speed25, .TA14, .TB14, .Other]
        case .AM_General:
            return [.Hummer, .Other]
        case .American_Bantam:
            return [.Roadster, .Other]
        case .American_Motors_AMC:
            return [.Ambassador, .Eagle, .Gremlin, .Javelin, .Marlin, .Matador, .Rambler, .Other]
        case .Amphicar:
            return [._770, .Other]
        case .Ariel:
            return [.Atom, .Other]
        case .Aston_Martin:
            return [.DB11, .DB12, .DB5, .DB7, .DB7_Vantage, .DB9, .DBS, .DBS_Superleggera, .DBX, .DBX707, .Rapide, .V12_Vantage, .V8_Vantage, .V8_Vantage_S, .Vanquish, .Vanquish_S, .Vantage, .Virage, .Other]
        case .Asuna:
            return [.GT, .Other]
        case .Audi:
            return [._100,._100_Series, ._200, ._4000, ._5000, ._A3, ._A3_Sportback, .A4, .A5, .A6, .A7, .A8, .Allroad, .Cabriolet, .e_tron, .e_tron_GT, .e_tron_S_Sportback, .e_tron_Sportback, .Q3, .Q4_e_tron, .Q4_e_tron_Sportback, .Q5, .Q7, .Q8, .Q8_e_tron_Sportback, .Quattro, .R8, .RS_3, .RS_4, .RS_5, .RS_6, .RS_7, .RS_e_tron_GT, .RS_Q8, .S3, .S4, .S5, .S6, .S7, .S8, .SQ5, .SQ7, .SQ8, .SQ8_e_tron, .SQ8_e_tron_Sportback, .TT, .TT_RS, .TTS, .V8]
        case .Aurora:
            return [.GRX, .Other]
        case .Austin:
            return [.A90, .Mini, .Other]
        case .Austin_Healey:
            return [._100S, ._3000, ._3000_MK_I, ._3000_MK_II, ._3000_MK_III, .Sprite, .Other]
        case .Avanti_II:
            return [.V6_Convertible, .V8_Coupe]
        case .Bentley:
            return [.Arnage, .Azure,.Bentayga,.Brooklands, .Continental, .Continental_Flying_Spur, .Continental_GT, .Continental_GT_Speed, .Continental_GT3, .Continental_GTC, .Continental_GTC_Speed, .Continental_Supersports, .Eight, .Flying_Spur, .Mulsanne, .Other]
        case .BMW:
            return [._1Series, ._1600, ._2Series, ._2002, ._3Series, ._3_0, ._4Series, ._428XI, ._5Series, ._6Series, ._7Series, ._8Series, .Alpina_B10, .i3, .i4, .i5, .i7, .i8, .Isetta, .iX, .M, .M2, .M240i, .M240i_xDrive, .M3, .M340i_xDrive, .M4, .M440i_xDrive, .M5, .M550i, .M6, .M8, .X1, .X2, .X3, .X3_M, .X4, .X4_M, .X5, .X5_M, .X6, .X6_M, .X7, .XM, .Z3, .Z3_M, .Z4, .Z4_M, .Z8, .Other]
        case .Bradley:
            return [.GT, .Other]
        case .BrightDrop:
            return [.Zevo_400, .Zevo_600, .Other]
        case .Bugatti:
            return [.Chiron, .Roadster, .Other]
        case .Buick:
            return [.Allure, .Cascada, .Century, .Electra, .Enclave, .Encore, .Encore_GX, .Envision, .Envista, .Gran_Sport, .Grand_National, .GSX_Gran_Sport, .LaCrosse, .LeSabre, .Lucerne, .Rainier, .Reatta, .Regal, .Rendezvous, .Riviera, .Roadmaster, .Skylark, .Special, .Super, .Verano, .Wildcat]
        case .Cadillac:
            return [.Allante, .ATS, .ATS_V, .Brougham, .Calais, .Catera, .Coupe_Deville, .CT4, .CT4_V, .CT5, .CT5_V, .CT6, .CT6_V, .CTS, .CTS_V, .DeVille, .DTS, .Eldorado, .ELR, .Escalade, .Escalade_ESV, .Escalade_EXT, .Escalade_EXV, .Fleetwood, .LaSalle, .LYRIQ, .Seville, .SRX, .STS, .STS_V, .XLR, .XLR_V, .XT4, .XT5, .XT6, .XTS, .Other]
        case .Caterham:
            return [.Super_7, .Other]
        case .Chrysler:
            return [._200, ._200S, ._300, .Aspen, .Cirrus, .Crossfire, .Daytona, .Grand_Caravan, .Imperial, .Intrepid, .LeBaron, .New_Yorker, .Newport, .Pacifica, .Pacifica_Hybrid, .Prowler, .PT_Cruiser, .Sebring, .TC, .Town_N_Country, .Voyager, .Windsor, .Other]
        case .Chevrolet:
            return [._12_Ton, ._1300, ._150, ._1500_Pickup, ._20_Pickup, ._210, ._2500_Cab_Chassis, ._2500_Pickup, ._30_Pickup, ._3100_Pickup, ._3500_Pickup, ._3500_Pickups, ._3600, .Aero, .Apache, .Astro, .Avalanche, .Aveo, .Bel_Air, .Biscayne, .Blazer, .Blazer_EV, .Bolt_EUV, .Bolt_EV, .C10, .Cab_And_Chassis, .Camaro, .Caprice, .Captiva, .Cavalier, .Chevelle, .Chevette, .Chevy, .Chevy_II, .Chevy_Van, .Cheyenne, .City_Express, .Cobalt, .Colorado, .Corvair, .Corvette, .Cruze, .Delray, .El_Camino, .Equinox, .Equinox_EV, .Express, .Express_1500, .Express_2500, .Express_3500, .Express_4500, .Express_Passenger, .FA_Master, .Fleetline, .Fleetmaster, .G_Series_Van, .HHR, .Impala, .Lumina, .Malibu, .Malibu_Hybrid, .Malibu_Maxx, .Master, .Master_85, .Monte_Carlo, .Nomad, .Nova, .Optra, .Orlando, .P30, .Pickup, .S10_Blazer, .Silverado, .Silverado_1500, .Silverado_1500_LTD, .Silverado_2500HD, .Silverado_3500, .Silverado_3500HD, .Silverado_3500HD_CC, .Silverado_EV, .Sonic, .Spark, .Spark_EV, .Special, .SS, .SSR_Pickup, .Styleline, .Stylemaster, .Suburban, .Superior, .Tahoe, .Tahoe_Hybrid, .TrailBlazer , .Traverse, .Traverse_Limited, .Trax, .Uplander, .Vega, .Venture, .Volt, .Other]
        case .Citroen:
            return [._2CV, .C6, .CX]
        case .Cord:
            return [._812, .Other]
        case .Dailmler:
            return [.Other]
        case .Daihatsu:
            return [.Copen, .Hijet, .Hijet_Truck, .Other]
        case .Datsun:
            return [._210, ._240Z,  ._280_Z, ._280_ZX, .Other]
        case .De_Soto:
            return [.Adventurer, .Custom, .Other]
        case .De_Tomaso:
            return [.Pantera, .Other]
        case .Divco:
            return [._206, .Other]
        case .Dodge:
            return [._024, ._12_Ton_Trucks, ._100, ._150, ._250, ._2500, ._350, ._3500, ._440, ._600, .Avenger, .Caliber, .Caravan, .Caravan_CV, .Challenger, .Charger, .Coronet, .Custom_880, .Dakota, .Dart, .Demon, .Diplomat, .Durango, .Dynasty, .Fargo, .Grand_Caravan, .Hornet, .Hornet_PHEV, .Intrepit, .Journey, .Magnum, .Mayfair, .Monaco, .Neon, .Neon_SRT4, .Nitro, .Polara, .Power_Ram, .Raider, .RAM, .RAM_1500_Pickup, .RAM_2500_Pickup, .RAM_3500_Pickup, .RAM_5500_Cab_Chassis, .RAM_Van, .Ramcharger, .Shadow, .Sprinter, .Sprinter_2500, .Sprinter_3500, .SRT_10, .Stealth, .Super_Bee, .SX_20, .Viper, .W_Series_Pickup,.Other]
        case .Eagle:
            return [.Other]
        case .Edsel:
            return [.Pacer, .Other]
        case .Honda:
            return[.Civic, .Civic_Coupe, .Civic_del_Sol, .Civic_Hatchback, .Civic_Sedan, .Civic_Sedan_EX, .Civic_Sedan_LX, .Civic_Type_R, .Other]
       case .Excalibur:
            return [.Phaeton, .Roadster, .Other]
        case .Factory_Five_Racing:
            return [.MK4_Roadster, .Other]
        case .Fargo:
            return [.pickup, .Other]
        case .Farrari:
            return [._250,._275, ._296_GTB, ._296_GTS, ._328, ._348, ._355_F1, ._355_Spider, ._360, ._360_Challenge_Stradale, ._365_GT, ._456, ._458, ._458_Italia, ._458_Spider, ._488, ._488_GTB, ._488_Pista, ._488_Pista_Spider, ._488_Spider, ._512, ._550, ._575, ._575M_Maranello, ._599, ._612, ._812_GTS, ._812_Superfast, ._California, ._California_T, .F12_belinetta, ._F12_TDF, .F355, .F430, .F430_Spider, .F512M, .F8_Spider, .F8_Triduto, .FF, .GTC4_Lusso, .Mondial, .Portfino, .Portfino_M, .Roma, .SF90_Spider, .SF90_Stradale, .Testarossa,.Other]
        case .Fiat:
            return [._124, ._124_Spider, ._500, ._500_Abarth, ._500E, ._500L, ._500X, ._600, ._850, .Coupe, .Spider, .X1_9, .Other]
        case .Fisker:
            return [.Karma, .Ocean, .Other]
        case .Ford:
            return [._1_Ton_Trucks, ._3_Ton_Trucks, ._4_Ton_Trucks, .Anglia, .Aspire, .Bronco, .Bronco_4WD, .Bronco_Sport, .C_Max, .C_Max_Energi, .Cobra, .Contour, .Country_Squire, .Coupe, .Courier_Pickup, .Crestline, .Crown_Victoria, .Crown_Victoria_Police_PKG, .Custom, .Custom_500, .Customline, .Deluxe, .E_150, .E_250, .E_350, .E_450, .E_Series, .E_Series_Cargo_Van, .E_Series_Cutaway, .E_Series_Cutaway_Chassis, .E_Transit_Chassis, .E_Transit_Cutaway, .Econoline, .EcoSport, .Edge, .Escape, .Excursion, .EXP, .Expedition, .Explorer, .Explorer_Sport_Trac, .F_1, .F_100, .F_150, .F_150_Lightning, .F_250, .F_250_HD_Series, .F_250_HD_Series_Crew_Cab, .F_250_Series_Crew_Cab, .F_250_Series_Standard, .F_350, .F_350_Series, .F_450, .F_550, .F_600, .F_650, .F_750, .F_Series_Pickup, .F_Super_Duty_Trucks, .Fairlane, .Fairmont_Futura, .Falcon, .Festiva, .Fiesta, .Five_Hundred, .Flex, .Focus, .Focus_Electric, .Freestar, .Freestyle, .Fusion, .Fusion_Energi, .Fusion_Hybrid, .Fusion_Plug_In_Hybrid, .Galaxie, .Gran_Torino, .GT, .LCF, .Maverick, .Meteor, .Model_A, .Model_AA, .Model_T, .Model_TT, .Mustang, .Mustang_Mach_E, .Pickup, .Polic_Interceptor_Sedan, .Polic_Interceptor_Utility, .Ranchero, .Ranger, .Sedan, .Super_Deluxe, .Super_Duty_E450_DRW, .Super_Duty_F600_DRW, .Super_Duty_F750, .Taurus, .Taurus_Polic_PKG, .TaurusX, .Thunderbird, .Torino, .Transit, .Transit_Cargo_Van, .Transit_Connect, .Transit_Connect_Cargo_Van, .Transit_Crew_Van, .Transit_Passanger_Wagon, .V8]
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
            return [.AC, .Acadian, .Acura, .Alfa_Romeo, .Allard, .Alvis, .AM_General, .American_Bantam, .American_Motors_AMC, .Amphicar, .Ariel, .Aston_Martin, .Asuna, .Audi, .Aurora, .Austin, .Austin_Healey, .Avanti_II]
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
