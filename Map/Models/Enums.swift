//
//  Enums.swift
//  Map
//
//  Created by saj panchal on 2023-08-25.
//

import Foundation

enum AppColors: String {
    case yellow = "ylwColor"
    case invertYellow = "invertYlwColor"
    case red = "rdColor"
    case darkRed = "darkRdColor"
    case lightRed = "lightRdColor"
    case invertRed = "invertRdColor"
    case orange = "orngColor"
    case invertOrange = "invertOrngColor"
    case purple = "prplColor"
    case invertPurple = "invertPrplColor"
    case green = "grnColor"
    case invertGreen = "invertGrnColor"
    case sky = "skyColor"
    case invertSky = "invertSkyColor"
    case lightSky = "lightSkyColor"
    case darkSky = "darkSkyColor"
    case pink = "pnkColor"
    case invertPink = "invertPnkColor"
    case lightBlue = "lightBluColor"
    case darkBlue = "darkBlueColor"
    case blueColor = "bluColor"
    case invertBlueColor = "invertBluColor"
}

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
    case locationUnselected
    case localSearchInProgress
    case localSearchCancelled
    case localSearchResultsAppear
    case showingNearbyLocations
    case searchBarActive
    case localSearchFailed
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
    case _1_Ton_Trucks, _3_Ton_Trucks, _4_Ton_Trucks, Anglia, Aspire, Bronco, Bronco_4WD, Bronco_Sport, C_Max, C_Max_Energi, Contour, Country_Squire, Courier_Pickup, Crestline, Crown_Victoria, Crown_Victoria_Police_PKG, Custom_500, Customline, Deluxe, E_150, E_250, E_350, E_450, E_Series, E_Series_Cargo_Van, E_Series_Cutaway, E_Series_Cutaway_Chassis, E_Transit_Chassis, E_Transit_Cutaway, Econoline, EcoSport, Edge, Escape, Excursion, EXP, Expedition, Explorer, Explorer_Sport_Trac, F_1, F_100, F_150, F_150_Lightning, F_250, F_250_HD_Series, F_250_HD_Series_Crew_Cab, F_250_Series_Crew_Cab, F_250_Series_Standard, F_350, F_350_Series, F_450, F_550, F_600, F_650, F_750, F_Series_Pickup, F_Super_Duty_Trucks, Fairlane, Fairmont_Futura, Falcon, Festiva, Fiesta, Five_Hundred, Flex, Focus, Focus_Electric, Freestar, Freestyle, Fusion, Fusion_Energi, Fusion_Hybrid, Fusion_Plug_In_Hybrid, Galaxie, Gran_Torino, LCF, Maverick, Meteor, Model_A, Model_AA, Model_T, Model_TT, Mustang, Mustang_Mach_E, Polic_Interceptor_Sedan, Polic_Interceptor_Utility, Ranchero, Ranger, Sedan, Super_Deluxe, Super_Duty_E450_DRW, Super_Duty_F600_DRW, Super_Duty_F750, Taurus, Taurus_Polic_PKG, TaurusX, Thunderbird, Torino, Transit, Transit_Cargo_Van, Transit_Connect, Transit_Connect_Cargo_Van, Transit_Crew_Van, Transit_Passanger_Wagon, Windstar
    case _11B
    case MT55
    case Electrified_G80, Electrified_GV70, G70, G80, G90, GV60, GV70, GV80, GV80_Coupe
    case Metro, Prizm
    case _1_Ton_Chassis_Cabs, _1_Ton_Pickups, _150_Pickup, _2500_Cab_chassis, _2500_HD_Chassis_Cabs, _350_Pickup, _3500_Cab_Chassis, _3500_Chassis_Cabs, _9300, Acadia, Acadia_Denali, _C_Series, C10_Pickup, C15, C5500, C6500, Caballero, Canyon, Denali, Envoy, Hummer_EV_Pickup, Hummer_EV_SUV, Jimmy, K15_Jimmy, New_Sierra_1500, New_Sierra_2500,  Safari, Savana_1500, Savana_2500, Savana_3500, Savana_4500_Cube_Van, Savana_Cargo_Van, Savana_Passenger, Savana_Van, Sierra_1500, Sierra_1500_Denali, Sierra_2500, Sierra_2500_Cab_Chassis, Sierra_2500_Denali_HD, Sierra_3500, Sierra_3500_Cab_Chassis, Sierra_3500_Denali_HD, Sierra_3500HD, Sierra_3500HD_CC, Sonoma, Sprint, Terrain, Terrain_Denali, Topkick, Vandura, Yukon, Yukon_XL, Yukon_XL_Denali
    case  _185, _195_Commercial, _258, _268, _338
    case  Accord, Accord_Coupe, Accord_Crosstour, Accord_Hybrid, Accord_Sedan, Acty, Civic, Civic_Coupe, Civic_del_Sol, Civic_Hatchback,Civic_Sedan, Civic_Sedan_Hybrid, Civic_Type_R, Clarity_Plug_In_Hybrid, CRV, CRV_Hybrid, CRZ, Crosstour, CRX, Del_Sol, Element, Fit, HRV, Insight, Odyssey, Passport, Pilot, Prelude, Prologue, Ridgeline, S2000, Stepwgn
    case Commodore
    case H1, H2, H3, H3T
    case Accent, Azera, Elantra, Elantra_Coupe, Elantra_GT, Elantra_Hybrid, Elantra_N, Elantra_Touring, Entourage, Equus, Genesis, Genesis_Coupe, IONIQ, IONIQ_5, IONIQ_5N, IONIQ_6, Kona, Kona_Electric, Kona_N, NEXO, Palisade, Santa_Cruz, Santa_Fe, Santa_Fe_Hybrid, Santa_fe_Plug_In_Hybrid, Santa_Fe_Sport, Santa_Fe_XL, Sonata, Sonata_Hybrid, Sonata_Plug_In_Hybrid, Tiburon, Tucson, Tucson_Hybrid, Tucson_Plug_In_Hybrid, Veloster, Veloster_N, Venue, Veracruz
    case Grenadier
    case EX, FX, G, I, JX35, M56x, Q45, Q50, Q60, Q70, Q70L, QX, QX30, QX50, QX55, QX56, QX60, QX70, QX80
    case Roadster_D
    case  _1110, _1310, KB_2, MXT, Scout, Scout_II
    case NRR, Rodeo, Trooper, VehiCross
    case _340, E_Pace, E_Type, F_Pace, F_Type, F_Type_R, I_Pace, Mark_II, S_Type, SS100, Vanden_Plas, X_Type, XE, XF, XFR, XFR_S, XJ, XJ_Series_Sedan, XJ12, XJ6, XJ8, XJL, XJR, XJRS, XJS, XJS_Convertible, XJS_Coupe, XJSC, XK, XKE, XKR
    case _4WD_Trucks, Cherokee, CJ, CJ_4WD, CJ_5, CJ_7, Comanche_Pickup, Commander, Compass, DJ, Gladiator, Grand_Cherokee, Grand_Cherokee_L, Grand_Cherokee_WK, Grand_Wagoneer, Grand_Wagoneer_L, J10, Liberty, Patriot, Renegade, Scrambler_4WD, TJ, Wagoneer, Wagoneer_L, Wagoneer_Limited, Wagoneer_S, Wrangler, Wrangler_JK_Unlimited
    case Interceptor
    case Commando
    case GS_6, Revero
    case Amanti, Borrego, Cadenza, Carnival, EV6, EV9, Forte, Forte_5_Door, Forte_Koup, Forte5, k5, K900, Magentis, Niro, Niro_EV, Niro_Plug_In_Hybrid, Optima, Optima_Hybrid, Optima_PHEV, Rio, Rio_5_Door, Rio5, Rondo, Sedona, Seltos, Sorento, Sorento_Hybrid, Sorento_Plug_In_Hybrid, Soul, Soul_EV, Spectra, Spectra_5, Sportage, Sportage_Hybrid, Sportage_Plug_In_Hybrid, Stinger, Telluride
    case Samara
    case _400, Aventador, Countach, Diablo, Gallardo, Huracan, Huracan_EVO, Huracan_Spyder, Murcielago, Sian_KFP_37, Urus
    case Scorpion, Ypsilon
    case Defender, Discovery, Discovery_Series_II, Discovery_Sport, Freelander, LR2, LR3, LR4, Range_Rover, Range_Rover_Evoque, Range_Rover_Sport, Range_Rover_Velar, Series_I, Series_II, Series_IIA, Series_III
    case CT, ES, GS, GS_F, GX, GX_550, HS, IS, IS_500, IS_C, IS_F, LC, LS, LS_500, LX, LX_600, NX, RC, RC_F, RX, RX_350H, RX_500H, RZ, SC, TX, TX_350, UX, UX_300H
    case Aviator, Corsair, Limousine, Mark_IV, Mark_LT, Mark_V, Mark_VI, Mark_VII, Mark_VIII, MKC, MKS, MKT, MKX, MKZ, Nautilus, Navigator, Premiere, Town_Car, Zephyr
    case Elan, Elise, Emira, Esprit, Europa, Evora, Evora_400, Exige, Seven
    case Air
    case _228, _4200_GT, Ghibi, GranCabrio, GranSport, GranTurismo, Granturismo_Convertible, Grecale, Grecale_Folgore, Levante, MC_20, Merak, Quattroporte, Spyder
    case _57, _62
    case _2WD_Pickup, _626, _B_Series, Bongo, CX_3, CX_30, CX_5, CX_50, CX_7, CX_70_MHEV, CX_70_PHEV, CX_9, CX_90, CX_90_MHEV, CX_90_PHEV, Mazda_2, Mazda_3, Mazda_5, Mazda_6, Mazda_Speed, Mazda_Speed3, Mazda_Speed6, Miata_MX5, MPV, MX_30, MX_5, MX_6, Protege, Protege_5, RX_3, RX_7, RX_8, Tribute
    case _12C, _12C_Spider, _540C, _570GT, _570S, _600LT, _650S, _675LT, _720S, _750S, _750S_Spider, _765LT, Artura, MP4_12C, Senna, Senna_GTR
    case AMG_GT, AMG_GTS, C_Class, CLA_Class, CLS_Class, E_Class, G_Class, GLC_Class, CLE_Class, S_Class, SL_Class
    case _190_Series, _200_Series, _220, _230, _240_Series, _280_series, _300_Series, _350_Series, _380_Series, _400_Series, _420_Series, _450_Series, _500_Series, _540_Series, _560_Series, _600_Series, A_Class, AMG_GLE_53, AMG_GLS_63, AMG_GT_R, AMG_GT_S, B_Class, CL_Class, CLA, CLE, CLK_Class, CLS, EQB, EQE, EQS, eSprinter_Cargo_Van, G_CLass, Gazelle, GL_Class, GLA, GLB, GLB250, GLC, GLE, GLK_Class, GLS, M_Class, Maybach, Metris_Cargo_Van, Metris_Passenger_Van, R_Class, S63_E_AMG, SLC_Class, SLK_Class, SLR_Class, SLS_AMG, Sprinter_4500, Sprinter_Cab_Chassis, Sprinter_Cargo_Van, Sprinter_Passenger_Van, Unimog
    case Caliente, Capri, Comet, Cougar, Cyclone, Grand_Marquis, M1, M100, Marauder, Medalist, Monarch, Montclair, Montego, Monterey, Park_Lane, Sable, Turnpike_Cruiser, Woody_Wagon
    case F, Magnette, MGA, MGB, Midget, TD, TF
    case _3_Door, _5_Door, Clubman, Convertible, Countryman, Paceman
    case _3000GT, Delica, Diamante, Eclipse, Eclipse_Cross, Endeavor, Galant, GTO, i_MiEV, Lancer, Lancer_Ralliart, Mirage, Mirage_G4, Montero, Montero_Sport, Outlander, Outlander_PHEV, Pajero, Pajero_IO, RVR
    case Minor
    case DX, SE
    case Metropolitan_1500, Series_Six
    case _240SX, _300ZX, _350Z, _370Z, Altima, Ariya, Armada, Axxess, Cab_and_Chassis, Cube, Elgrand, Fairlady, Frontier, GTR, Hardbody_2WD, Juke, Kicks, Kicks_Play, Leaf, Maxima, Micra, Murano, Murano_CrossCabriolet, NV, NV_2500, NV_3500, NV_Cargo, NV200, NV200_Compact_Cargo, Pathfinder, Pathfinder_Armada, Qashqai, Quest, Roque, Sentra, Slivia, Skyline, Stagea, Terrano, Titan, Titan_XD, Trucks_4WD, Van, Versa, Versa_Note, X_Trail, Xterra, Z
    case _442, _88, _98, _98_Regency_Elite, Alero, Custom_Cruiser, Cutlass, Cutlass_Supreme, Intrigue, Omega, Starfire, Toronado, Touring
    case Caribbean
    case Lima
    case _106
    case Barracuda, Belvedere, Breeze, Cambridge, Duster, GTX, PD_Deluxe, Road_Runner, Satellite, Scamp, Sport_Fury, Valiant
    case _1, _2
    case  _2_Plus_2, Acadian, Beaumont, Bonneville, Chieftain, Fiero, Firebird, Firefly, G3, G5, G6, G8, Grand_AM, Grand_LeMans, Grand_Prix, Grand_Ville, Laurentian, LeMans, Montana, Montana_SV6, Parisienne, Pursuit, Solstice, Star_Chief, Streamliner, Sunfire, Tempest, Torrent, Trans_Sport, Vibe, Wave
    case _356, _718_Boxster, _718_Cayman, _718_Spyder, _911, _911_America_Roadster, _911_Carrera_GTS, _911_GT3, _911_GT3_RS, _911_Targa_4, _911T, _914, _924, _928, _928_S4, _944, _951, _964, _968, Boxster, Carrera_GT, Cayenne, Cayman, Macan, Panamera, Speedster, Taycan
    case  _1500, _1500_Classic,  _4500, _5500, _5500_HD_Chassis, Promaster, Promaster_1500, Promaster_2500, Promaster_3500, ProMaster_Cargo_Van, ProMaster_City, Promaster_City_Wagon, ProMaster_Window_Van, Ram_5500_Cab_Chassis, Ram_CV, Wagon
    case _4
    case R1S, R1T
    case Black_Badge_Cullinan, Corniche, Cullinan, Dawn, Ghost, Phantom, Phantom_Coupe, Silver_Shadow, Silver_Spirit, Silver_Spur, Silver_Wraith, Spectre, Wraith
    case P5
    case _9_2X, _9_3, _9_5, _9_7X, _900, _9000
    case _4DR_Wagon, Astra, Aura, Ion, L200, SC1, Sky, SL, Vue
    case FR_S, iM, iQ, tC, xB, xD
    case Leon
    case EQ_Fortwo, fortwo, fortwo_Electric_Drive
    case C8_Laviolette
    case Vanguard
    case Bullet
    case Champion, Hawk, Transtar
    case _4_DR, Ascent, B9_Tribeca, Baja, BRZ, Crosstrek, CrossTrek_Plug_in_Hybrid, Forester, Hatchback, Impreza, Impreza_WRX, Impreza_WRX_STi, Legacy, Outback, Samback, Sambar, Solterra, SVX, Tribeca, WRX, WRX_STi, XV_CrossTrek, XV_Crosstrek_Hybrid
    case Alpine, Tiger
    case Aerio, Carry, Equator, Grand_Vitara, Jimmy_4WD, Kizashi, Sidekick, Swift, SX4, Vitara, XL7
    case Cybertruck, Model_3, Model_S, Model_X, Model_Y
    case _2WD_Compact_Pickups, _4Runner, _4Runner_4WD, _4WD_Compact_Pickups, _4WD_Pickups, _86, Alphard, Avalon, bZ4X, C_HR, Camry, Camry_Solara, Celica, Commercial_Chassis_Cabs, Corolla, Corolla_Cross, Corolla_Hatchback, Corolla_iM, Corona, Cressida, Crown, Crown_Signia, Echo, Estima, FJ_Cruiser, GR_86, GR_Corolla, GR_Supra, Grand_Highlander, Hiace, Highlander, Land_Cruiser, Lite_Ace, Matrix, Mirai, MR2, MR2_Spyder, Prius, Prius_C, Prius_Plug_In, Prius_Prime, Prius_V, RAV4, RAV4_Plug_in_Hybrid, RAV4_Prime, Sequoia, Sienna, Soarer, Solara, Supra, Tacoma, Tacoma_Hybrid, Tacoma_Pickups, Tercel, Tundra, Van_Wagon, Venza, Yaris
    case GT6, Spitfire, Stag, TR
    case Tuscan
    case VF_8
   // case _411, Arteon, Atlas, Atlas_Cross_Sport, Beetle, Cabrio, Cabriolet, CC, Corrado, E_Golf, Eos, Eurovan, GLI, Golf, Golf_Alltrack, Golf_GTI, Golf_R, Golf_SportWagen, Golf_Wagon, GTI, ID_4, Jetta, Jet
    
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
    case Factory_Five_Racing, Fargo, Farrari, Fiat, Fisker, Ford, Franklin, Freightliner
    case Genesis, Geo, GMC
    case Hino, Holden, Honda, Hudson, Hummer, Hyundai
    case INEOS, Infiniti, Intermeccanica, International, Isuzu
    case Jaguar, Jeep, Jensen, Jensen_Healey
    case Kaiser, Karma, Kia
    case Lada, Lamborghini, Lancia, Land_Rover, Lexus, Lincoln, Lotus, Lucid
    case Manic, Maserati, Maybach, Mazda, McLaren, Mercedes_AMG, Mercedes_Benz, Mercury, MG, Mini, Mitsubishi, Morgan, Morris, MV_1
    case Nash, Nissan
    case Oldsmobile
    case Packard, Panther, Peugeot, Plymouth, Polestar, Pontiac, Porsche
    case Ram, Rambler, Renault, Rivian, Rolls_Royce, Rover
    case Saab, Saturn, Scion, Seat, Shelby, Smart, Spyker, Standard, Sterling, Studebaker, Subaru, Sunbeam, Suzuki
    case Tesla, Toyota, Triumph, TVR
    case VinFast, Volkswagen
 
    
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
            return [._1_Ton_Trucks, ._3_Ton_Trucks, ._4_Ton_Trucks, .Anglia, .Aspire, .Bronco, .Bronco_4WD, .Bronco_Sport, .C_Max, .C_Max_Energi, .Cobra, .Contour, .Country_Squire, .Coupe, .Courier_Pickup, .Crestline, .Crown_Victoria, .Crown_Victoria_Police_PKG, .Custom, .Custom_500, .Customline, .Deluxe, .E_150, .E_250, .E_350, .E_450, .E_Series, .E_Series_Cargo_Van, .E_Series_Cutaway, .E_Series_Cutaway_Chassis, .E_Transit_Chassis, .E_Transit_Cutaway, .Econoline, .EcoSport, .Edge, .Escape, .Excursion, .EXP, .Expedition, .Explorer, .Explorer_Sport_Trac, .F_1, .F_100, .F_150, .F_150_Lightning, .F_250, .F_250_HD_Series, .F_250_HD_Series_Crew_Cab, .F_250_Series_Crew_Cab, .F_250_Series_Standard, .F_350, .F_350_Series, .F_450, .F_550, .F_600, .F_650, .F_750, .F_Series_Pickup, .F_Super_Duty_Trucks, .Fairlane, .Fairmont_Futura, .Falcon, .Festiva, .Fiesta, .Five_Hundred, .Flex, .Focus, .Focus_Electric, .Freestar, .Freestyle, .Fusion, .Fusion_Energi, .Fusion_Hybrid, .Fusion_Plug_In_Hybrid, .Galaxie, .Gran_Torino, .GT, .LCF, .Maverick, .Meteor, .Model_A, .Model_AA, .Model_T, .Model_TT, .Mustang, .Mustang_Mach_E, .Pickup, .Polic_Interceptor_Sedan, .Polic_Interceptor_Utility, .Ranchero, .Ranger, .Sedan, .Super_Deluxe, .Super_Duty_E450_DRW, .Super_Duty_F600_DRW, .Super_Duty_F750, .Taurus, .Taurus_Polic_PKG, .TaurusX, .Thunderbird, .Torino, .Transit, .Transit_Cargo_Van, .Transit_Connect, .Transit_Connect_Cargo_Van, .Transit_Crew_Van, .Transit_Passanger_Wagon, .V8, .Windstar,.Other]
        case .Franklin:
            return [._11B, .Other]
        case .Freightliner:
            return [.MT55, .Sprinter, .Other]
        case .Genesis:
            return [.Electrified_G80, .Electrified_GV70, .G70, .G80, .G90, .GV60, .GV70, .GV80, .GV80_Coupe, .Other]
        case .Geo:
            return [.Metro, .Prizm, .Other]
        case .GMC:
            return [._1_Ton_Chassis_Cabs, ._1_Ton_Pickups, ._100, ._150_Pickup, ._1500_Pickup, ._2500_Cab_chassis, ._2500_HD_Chassis_Cabs, ._2500_Pickup, ._350_Pickup, ._3500, ._3500_Cab_Chassis, ._3500_Chassis_Cabs, ._3500_Pickup, ._9300, .Acadia, .Acadia_Denali, .Apache, ._C_Series, .C10_Pickup, .C15, .C5500, .C6500, .Caballero, .Canyon, .Denali, .Envoy, .Hummer_EV_Pickup, .Hummer_EV_SUV, .Jimmy, .K15_Jimmy, .New_Sierra_1500, .New_Sierra_2500, .Pickup, .Safari, .Savana_1500, .Savana_2500, .Savana_3500, .Savana_4500_Cube_Van, .Savana_Cargo_Van, .Savana_Passenger, .Savana_Van, .Sierra_1500, .Sierra_1500_Denali, .Sierra_2500, .Sierra_2500_Cab_Chassis, .Sierra_2500_Denali_HD, .Sierra_3500, .Sierra_3500_Cab_Chassis, .Sierra_3500_Denali_HD, .Sierra_3500HD, .Sierra_3500HD_CC, .Sonoma, .Sprint, .Suburban, .Terrain, .Terrain_Denali, .Topkick, .Vandura, .Yukon, .Yukon_XL, .Yukon_XL_Denali, .Other]
        case .Hino:
            return [._155, ._185, ._195_Commercial, ._258, ._268, ._338, .Other]
        case .Holden:
            return [.Other]
        case .Honda:
            return[._600, .Accord, .Accord_Coupe, .Accord_Crosstour, .Accord_Hybrid, .Accord_Sedan, .Acty, .Civic, .Civic_Coupe, .Civic_del_Sol, .Civic_Hatchback, .Civic_Sedan, .Civic_Sedan_Hybrid, .Civic_Type_R, .Clarity_Plug_In_Hybrid, .CRV, .CRV_Hybrid, .CRZ, .Crosstour, .CRX, .Del_Sol, .Element, .Fit, .HRV, .Insight, .Odyssey, .Passport, .Pilot, .Prelude, .Prologue, .Ridgeline, .S2000, .Stepwgn, .Other]
        case .Hudson:
            return [.Commodore, .Other]
        case .Hummer:
            return [.H1, .H2, .H3, .H3T, .Other]
        case .Hyundai:
            return [.Accent, .Azera, .Elantra, .Elantra_Coupe, .Elantra_GT, .Elantra_Hybrid, .Elantra_N, .Elantra_Touring, .Entourage, .Equus, .Genesis, .Genesis_Coupe, .IONIQ, .IONIQ_5, .IONIQ_5N, .IONIQ_6, .Kona, .Kona_Electric, .Kona_N, .NEXO, .Palisade, .Santa_Cruz, .Santa_Fe, .Santa_Fe_Hybrid, .Santa_fe_Plug_In_Hybrid, .Santa_Fe_Sport, .Santa_Fe_XL, .Sonata, .Sonata_Hybrid, .Sonata_Plug_In_Hybrid, .Tiburon, .Tucson, .Tucson_Hybrid, .Tucson_Plug_In_Hybrid, .Veloster, .Veloster_N, .Venue, .Veracruz, .Other]
        case .INEOS:
            return [.Grenadier, .Other]
        case .Infiniti:
            return [.EX, .FX, .G, .I, .JX35, .M, .M56x, .Q45, .Q50, .Q60, .Q70, .Q70L, .QX, .QX30, .QX50, .QX55, .QX56, .QX60, .QX70, .QX80, .Other]
        case .Intermeccanica:
            return [.Roadster_D, .Other]
        case .International:
            return [._100, ._1110, ._1310, .KB_2, .MXT, .Scout, .Scout_II, .Other]
        case .Isuzu:
            return [.NRR, .Rodeo, .Trooper, .VehiCross, .Other]
        case .Jaguar:
            return [._340, .E_Pace, .E_Type, .F_Pace, .F_Type, .F_Type_R, .I_Pace, .Mark_II, .S_Type, .SS100, .Vanden_Plas, .X_Type, .XE, .XF, .XFR, .XFR_S, .XJ, .XJ_Series_Sedan, .XJ12, .XJ6, .XJ8, .XJL, .XJR, .XJRS, .XJS, .XJS_Convertible, .XJS_Coupe, .XJSC, .XK, .XKE, .XKR, .Other]
        case .Jeep:
            return [._4WD_Trucks, .Cherokee, .CJ, .CJ_4WD, .CJ_5, .CJ_7, .Comanche_Pickup, .Commander, .Compass, .DJ, .Gladiator, .Grand_Cherokee, .Grand_Cherokee_L, .Grand_Cherokee_WK, .Grand_Wagoneer, .Grand_Wagoneer_L, .J10, .Liberty, .Patriot, .Renegade, .Scrambler_4WD, .TJ, .Wagoneer, .Wagoneer_L, .Wagoneer_Limited, .Wagoneer_S, .Wrangler, .Wrangler_JK_Unlimited, .Other]
        case .Jensen:
            return [.Interceptor, .Other]
        case .Jensen_Healey:
            return [.Roadster, .Other]
        case .Kaiser:
            return [.Commando, .Other]
        case .Karma:
            return [.GS_6, .Revero, .Other]
        case .Kia:
            return [.Amanti, .Borrego, .Cadenza, .Carnival, .EV6, .EV9, .Forte, .Forte_5_Door, .Forte_Koup, .Forte5, .k5, .K900, .Magentis, .Niro, .Niro_EV, .Niro_Plug_In_Hybrid, .Optima, .Optima_Hybrid, .Optima_PHEV, .Rio, .Rio_5_Door, .Rio5, .Rondo, .Sedona, .Seltos, .Sorento, .Sorento_Hybrid, .Sorento_Plug_In_Hybrid, .Soul, .Soul_EV, .Spectra, .Spectra_5, .Sportage, .Sportage_Hybrid, .Sportage_Plug_In_Hybrid, .Stinger, .Telluride]
        case .Lada:
            return [.Samara, .Other]
        case .Lamborghini:
            return [._350, ._400, .Aventador, .Countach, .Diablo, .Gallardo, .Huracan, .Huracan_EVO, .Huracan_Spyder, .Murcielago, .Sian_KFP_37, .Urus, .Other]
        case .Lancia:
            return [.Scorpion, .Ypsilon, .Other]
        case .Land_Rover:
            return [.Defender, .Discovery, .Discovery_Series_II, .Discovery_Sport, .Freelander, .LR2, .LR3, .LR4, .Range_Rover, .Range_Rover_Evoque, .Range_Rover_Sport, .Range_Rover_Velar, .Series_I, .Series_II, .Series_IIA, .Series_III, .Other]
        case .Lexus:
            return [.CT, .ES, .GS, .GS_F, .GX, .GX_550, .HS, .IS, .IS_500, .IS_C, .IS_F, .LC, .LS, .LS_500, .LX, .LX_600, .NX, .RC, .RC_F, .RX, .RX_350H, .RX_500H, .RZ, .SC, .TX, .TX_350, .UX, .UX_300H, .Other]
        case .Lincoln:
            return [.Aviator, .Continental, .Corsair, .Limousine, .LS, .Mark_IV, .Mark_LT, .Mark_V, .Mark_VI, .Mark_VII, .Mark_VIII, .MKC, .MKS, .MKT, .MKX, .MKZ, .Nautilus, .Navigator, .Premiere, .Town_Car, .Zephyr, .Other]
        case .Lotus:
            return [.Elan, .Elise, .Emira, .Esprit, .Europa, .Evora, .Evora_400, .Exige, .Seven, .Other]
        case .Lucid:
            return [.Air, .Other]
        case .Manic:
            return [.GT, .Other]
        case .Maserati:
            return [._228, ._4200_GT, .Coupe, .Ghibi, .GranCabrio, .GranSport, .GranTurismo, .Granturismo_Convertible, .Grecale, .Grecale_Folgore, .Levante, .MC_20, .Merak, .Quattroporte, .Spyder, .Other]
        case .Maybach:
            return [._57, ._62, .Other]
        case .Mazda:
            return [._2WD_Pickup, ._626, ._B_Series, .Bongo, .CX_3, .CX_30, .CX_5, .CX_50, .CX_7, .CX_70_MHEV, .CX_70_PHEV, .CX_9, .CX_90, .CX_90_MHEV, .CX_90_PHEV, .Mazda_2, .Mazda_3, .Mazda_5, .Mazda_6, .Mazda_Speed, .Mazda_Speed3, .Mazda_Speed6, .Miata_MX5, .MPV, .MX_30, .MX_5, .MX_6, .Protege, .Protege_5, .RX_3, .RX_7, .RX_8, .Tribute, .Other]
        case .McLaren:
            return [._12C, ._12C_Spider, ._540C, ._570GT, ._570S, ._600LT, ._650S, ._675LT, ._720S, ._750S, ._750S_Spider, ._765LT, .Artura, .GT, .MP4_12C, .Senna, .Senna_GTR, .Other]
        case .Mercedes_AMG:
            return [.AMG_GT, .AMG_GTS, .C_Class, .CLA_Class, .CLS_Class, .E_Class, .G_Class, .GLC_Class, .CLE_Class, .S_Class, .SL_Class, .Other]
        case .Mercedes_Benz:
            return [._190_Series, ._200_Series, ._220, ._230, ._240_Series, ._250, ._280_series, ._300_Series, ._350_Series, ._380_Series,. _400_Series, ._420_Series, ._450_Series, ._500_Series, ._540_Series, ._560_Series, ._600_Series, .A_Class, .AMG_GLE_53, .AMG_GLS_63, .AMG_GT, .AMG_GT_R, .AMG_GT_S, .B_Class, .C_Class, .CL_Class, .CLA, .CLE, .CLK_Class, .CLS, .E_Class, .EQB, .EQE, .EQS, .eSprinter_Cargo_Van, .G_CLass, .Gazelle, .GL_Class, .GLA, .GLB, .GLB250, .GLC, .GLE, .GLK_Class, .GLS, .M_Class, .Maybach, .Metris_Cargo_Van, .Metris_Passenger_Van, .R_Class, .S_Class, .S63_E_AMG, .SL_Class, .SLC_Class, .SLK_Class, .SLR_Class, .SLS_AMG, .Sprinter, .Sprinter_4500, .Sprinter_Cab_Chassis, .Sprinter_Cargo_Van, .Sprinter_Passenger_Van, .Unimog, .Other]
        case .Mercury:
            return [.Caliente, .Capri, .Comet, .Cougar, .Custom, .Cyclone, .Eight, .Grand_Marquis, .M1, .M100, .Marauder, .Medalist, .Meteor, .Monarch, .Montclair, .Montego, .Monterey, .Park_Lane, .Sable, .Turnpike_Cruiser, .Voyager, .Woody_Wagon, .Zephyr, .Other]
        case .MG:
            return [.F, .Magnette, .MGA, .MGB, .Midget, .TD, .TF, .Other]
        case .Mini:
            return [._3_Door, ._5_Door, .Clubman, .Convertible, .Countryman, .Coupe, .Paceman, .Roadster, .Other]
        case .Mitsubishi:
            return [._3000GT, .Delica, .Diamante, .Eclipse, .Eclipse_Cross, .Endeavor, .Galant, .GTO, .i_MiEV, .Lancer, .Lancer_Ralliart, .Mirage, .Mirage_G4, .Montero, .Montero_Sport, .Outlander, .Outlander_PHEV, .Pajero, .Pajero_IO, .RVR, .Other]
        case .Morgan:
            return [.Roadster, .Other]
        case .Morris:
            return [.Minor, .Other]
        case .MV_1:
            return [.DX, .SE, .Other]
        case .Nash:
            return [.Metropolitan_1500, .Series_Six, .Other]
        case .Nissan:
            return [._240SX, ._300ZX, ._350Z, ._370Z, .Altima, .Ariya, .Armada, .Axxess, .Cab_and_Chassis, .Cube, .Elgrand, .Fairlady, .Frontier, .GTR, .Hardbody_2WD, .Juke, .Kicks, .Kicks_Play, .Leaf, .Maxima, .Micra, .Murano, .Murano_CrossCabriolet, .NV, .NV_2500, .NV_3500, .NV_Cargo, .NV200, .NV200_Compact_Cargo, .NX, .Pathfinder, .Pathfinder_Armada, .Qashqai, .Quest, .Roque, .Safari, .Sentra, .Slivia, .Skyline, .Stagea, .Terrano, .Titan, .Titan_XD, .Trucks_4WD, .Van, .Versa, .Versa_Note, .X_Trail, .Xterra, .Z]
        case .Oldsmobile:
            return  [._442, ._88, ._98, ._98_Regency_Elite, .Alero, .Custom_Cruiser, .Cutlass, .Cutlass_Supreme, .Intrigue, .Omega, .Starfire, .Toronado, .Touring, .Other]
        case .Packard:
            return [.Caribbean, .Other]
        case .Panther:
            return [.Lima, .Other]
        case .Peugeot:
            return [._106, .Other]
        case .Plymouth:
            return [.Barracuda, .Belvedere, .Breeze, .Cambridge, .Deluxe, .Duster, .GTX, .PD_Deluxe, .Prowler, .Road_Runner, .Satellite, .Scamp, .Sport_Fury, .Suburban, .Valiant]
        case .Polestar:
            return [._1, ._2, .Other]
        case .Pontiac:
            return [._2_Plus_2, .Acadian, .Beaumont, .Bonneville, .Chieftain, .Fiero, .Firebird, .Firefly, .G3, .G5, .G6, .G8, .Grand_AM, .Grand_LeMans, .Grand_Prix, .Grand_Ville, .GTO, .Laurentian, .LeMans, .Montana, .Montana_SV6, .Parisienne, .Pathfinder, .Pursuit, .Solstice, .Star_Chief, .Streamliner, .Sunfire, .Tempest, .Torrent, .Trans_Sport, .Vibe, .Wave, .Other]
        case .Porsche:
            return [._356, ._718_Boxster, ._718_Cayman, ._718_Spyder, ._911, ._911_America_Roadster, ._911_Carrera_GTS, ._911_GT3, ._911_GT3_RS, ._911_Targa_4, ._911T, ._914, ._924, ._928, ._928_S4, ._944, ._951, ._964, ._968, .Boxster, .Carrera_GT, .Cayenne, .Cayman, .Macan, .Panamera, .Speedster, .Taycan, .Other]
        case .Ram:
            return [._100, ._150, ._1500, ._1500_Classic, ._250, ._2500, ._350, ._3500, ._4500, ._5500, ._5500_HD_Chassis, .Dakota, .Promaster, .Promaster_1500, .Promaster_2500, .Promaster_3500, .ProMaster_Cargo_Van, .ProMaster_City, .Promaster_City_Wagon, .ProMaster_Window_Van, .Ram_5500_Cab_Chassis, .Ram_CV, .SRT_10, .Wagon, .Other]
        case .Rambler:
            return [.Other]
        case .Renault:
            return [._4, .Spider, .Other]
        case .Rivian:
            return [.R1S, .R1T, .Other]
        case .Rolls_Royce:
            return [.Black_Badge_Cullinan, .Corniche, .Cullinan, .Dawn, .Ghost, .Phantom, .Phantom_Coupe, .Silver_Shadow, .Silver_Spirit, .Silver_Spur, .Silver_Wraith, .Spectre, .Wraith]
        case .Rover:
            return [.P5, .Other]
        case .Saab:
            return [._9_2X, ._9_3, ._9_5, ._9_7X, ._900, ._9000, .Other]
        case .Saturn:
            return [._4DR_Wagon, .Astra, .Aura, .Ion, .L200, .SC1, .Sky, .SL, .Vue, .Other]
        case .Scion:
            return [.FR_S, .iM, .iQ, .tC, .xB, .xD, .Other]
        case .Seat:
            return [.Leon, .Other]
        case .Shelby:
            return [.Cobra, .F_150, .GT, .Other]
        case .Smart:
            return [.EQ_Fortwo, .fortwo, .fortwo_Electric_Drive, .Roadster, .Other]
        case .Spyker:
            return [.C8_Laviolette, .Other]
        case .Standard:
            return [.Vanguard, .Other]
        case .Sterling:
            return [._360, .Bullet, .Other]
        case .Studebaker:
            return [.Champion, .Commander, .Hawk, .Other, .Transtar]
        case .Subaru:
            return [._4_DR, .Ascent, .B9_Tribeca, .Baja, .BRZ, .Crosstrek, .CrossTrek_Plug_in_Hybrid, .Forester, .Hatchback, .Impreza, .Impreza_WRX, .Impreza_WRX_STi, .Legacy, .Outback, .Samback, .Sambar, .Solterra, .SVX, .Tribeca, .WRX, .WRX_STi, .XV_CrossTrek, .XV_Crosstrek_Hybrid, .Other]
        case .Sunbeam:
            return [.Alpine, .Tiger, .Other]
        case .Suzuki:
            return [.Aerio, .Carry, .Equator, .Grand_Vitara, .Jimmy_4WD, .Kizashi, .Sidekick, .Swift, .SX4, .Vitara, .XL7]
        case .Tesla:
            return [.Cybertruck, .Model_3, .Model_S, .Model_X, .Model_Y, .Roadster]
        case .Toyota:
            return [._2WD_Compact_Pickups, ._4Runner, ._4Runner_4WD, ._4WD_Compact_Pickups, ._4WD_Pickups, ._86, .Alphard, .Avalon, .bZ4X, .C_HR, .Camry, .Camry_Solara, .Celica, .Century, .Commercial_Chassis_Cabs, .Corolla, .Corolla_Cross, .Corolla_Hatchback, .Corolla_iM, .Corona, .Cressida, .Crown, .Crown_Signia, .Echo, .Estima, .FJ_Cruiser, .GR_86, .GR_Corolla, .GR_Supra, .Grand_Highlander, .Hiace, .Highlander, .Land_Cruiser, .Lite_Ace, .Mark_II, .Matrix, .Mirai, .MR2, .MR2_Spyder, .Prius, .Prius_C, .Prius_Plug_In, .Prius_Prime, .Prius_V, .RAV4, .RAV4_Plug_in_Hybrid, .RAV4_Prime, .Sequoia, .Sienna, .Soarer, .Solara, .Supra, .Tacoma, .Tacoma_Hybrid, .Tacoma_Pickups, .Tercel, .Tundra, .Van_Wagon, .Venza, .Yaris, .Other]
        case .Triumph:
            return [.GT6, .Spitfire, .Stag, .TR, .Other]
        case .TVR:
            return [.Tuscan, .Other]
        case .VinFast:
            return [.VF_8, .Other]
        case .Volkswagen:
            return []
        }

        
        
    }
    var id: Self {
        self
    }
}
enum Alphbets: String, CaseIterable, Identifiable {
    case A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,R,S,T,U//,V,W,X,Y,Z
 
    var makes: [VehicleMake] {
        switch self {
        case .A:
            return [.AC, .Acadian, .Acura, .Alfa_Romeo, .Allard, .Alvis, .AM_General, .American_Bantam, .American_Motors_AMC, .Amphicar, .Ariel, .Aston_Martin, .Asuna, .Audi, .Aurora, .Austin, .Austin_Healey, .Avanti_II]
        case .B:
            return [.Bentley, .BMW, .BrightDrop, .Bugatti, .Buick]
        case .C:
            return [.Cadillac, .Caterham, .Chevrolet, .Chrysler, .Citroen, .Cord]
        case .D:
            return [.Daihatsu, .Dailmler, .Datsun, .De_Soto, .De_Tomaso, .Divco, .Dodge]
        case .E:
            return [.Eagle, .Edsel, .Excalibur]
        case .F:
            return[.Factory_Five_Racing, .Fargo ,.Farrari, .Fiat, .Fisker, .Ford, .Franklin, .Freightliner]
        case .G:
            return [.Genesis, .Geo, .GMC]
        case .H:
            return[.Hino, .Holden, .Honda, .Hudson, .Hummer, .Hyundai]
        case .I:
            return [.INEOS, .Infiniti, .Intermeccanica, .International, .Isuzu]
        case .J:
            return [.Jaguar, .Jeep, .Jensen, .Jensen_Healey]
        case .K:
            return [.Kaiser, .Karma, .Kia]
        case .L:
            return[.Lada, .Lamborghini, .Lancia, .Land_Rover, .Lexus, .Lincoln, .Lotus, .Lucid]
        case .M:
            return [.Manic, .Maserati, .Maybach, .Mazda, .McLaren, .Mercedes_AMG, .Mercedes_Benz, .Mercury, .MG, .Mini, .Mitsubishi, .Morgan, .Morris, .MV_1]
        case .N:
            return [.Nash, .Nissan]
        case .O:
            return [.Oldsmobile]
        case .P:
            return [.Packard, .Panther, .Peugeot, .Plymouth, .Polestar, .Pontiac, .Porsche]
        case .R:
            return [.Ram, .Rambler, .Renault, .Rivian, .Rolls_Royce, .Rover]
        case .S:
            return [.Saab, .Saturn, .Scion, .Seat, .Shelby, .Smart, .Spyker, .Standard, .Sterling, .Studebaker, .Subaru, .Sunbeam, .Suzuki]
        case .T:
            return[.Tesla, .Toyota, .Triumph, .TVR]
        case .U:
            return[]
        }
    }
    var id: Self {
        self
    }
}

enum EngineType: String, CaseIterable, Identifiable  {
    case Gas
    case EV
    case Hybrid
    var id: Self {
        self
    }
}
enum FuelMode: String, CaseIterable, Identifiable {
    case Gas
    case EV
    var id: Self {
        self
    }
}

enum DistanceUnit: String, CaseIterable, Identifiable  {
    case km
    case miles
    var id: Self {
        self
    }
}
enum FuelUnit: String, CaseIterable, Identifiable  {
    case Litre
    case Gallon
    case Percent = "%"
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
