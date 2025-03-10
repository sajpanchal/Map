//
//  DirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI
///framework that contains tasks to inspect, play, capture and process the audio video content.
import AVFoundation
///a view responsible to show the direction signs along with the instruction text on top of the screen while navigating.

struct DirectionHeaderView: View {
    ///environment variable to get the color mode of the phone
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///variable that stores the image name for various direction signs.
    var directionSign: String?
    ///stores distance from the next step in string format.
    var nextStepDistance: String
    ///stores the instruction string.
    var instruction: String
    ///flag that is bound to MapSwiftUI. it is set when user taps on this view to see the expanded directions list view.
    @Binding var showDirectionsList: Bool
    @Binding var height: CGFloat
    ///locationDataManager is an instance of a class that has a delegate of LocationManager and its methods.
    @StateObject var locationDataManager: LocationDataManager
   ///speech view Model object that controls the audio session and speech synthesizer operations.
    @StateObject var speechViewModel: SpeechViewModel
    ///utterance distance variable will store the step distance from the next step to be spoken by speech synthesizer
    @State private var utteranceDistance: String = ""
    ///flag to indicate whether the current step has been exited by user.
    @State private var isStepExited = false
    ///range is a variable to store the step range for entry or exit.
    @State private var range = 20.0
    @State var maxDistance = "0.0"
    
    var body: some View {
        VStack {
            ///enclosing the directions and instruction view in horizontal stack.
            HStack {
                ///shows direction sign and next step distance below it.
                VStack {
                    ///if directionSign is not empty show the image.
                    if let directionSign = directionSign {
                        Image(systemName: directionSign)
                            .font(.title)
                            .fontWeight(.black)
                            .padding(.top, 5)
                            .foregroundStyle(.gray)
                    }
                    ///show the distance from next step
                    if !instruction.contains("Re-calculating the route...") && !instruction.contains("No routes available"){
                        Text("\(nextStepDistance)")
                            .padding(.bottom, 5)
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundStyle(Color(AppColors.invertRed.rawValue))
                            .onChange(of: nextStepDistance, alertUserWithVoiceNavigation)
                    }
                }
                ///add a space between directions and instruction stacks.
                Spacer()
                    ///showing the instruction in a text format
                    Text(instruction)
                    .onAppear(perform: prepareForVoiceNavigation)
                    .onChange(of: instruction, prepareForVoiceNavigation)
                    .padding(10)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundStyle(.gray)
                ///add a spacer to the right of the instruction view.
                Spacer()
            }
            if !showDirectionsList {
                ExpandViewSymbol()
            }
        }
        .padding(.horizontal,10)
        ///apply the black gradient to entire view.
        .background(bgMode == .dark ? Color.black.gradient : Color.white.gradient)
    }
    func startVoiceNavigation(with utterance: String) {
        if speechViewModel.isMuted {
            speechViewModel.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            return
        }
        ///if instruction is empty return the function call
        if instruction.isEmpty || utterance.isEmpty {
            print("instruction empty")
            speechViewModel.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            return
        }
        ///if instruction says re-calculating the route stop synthesizer to speak immidiately.
        if instruction.contains("Re-calculating the route...") {
            speechViewModel.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            return
        }
        ///
        if speechViewModel.audioSession.category != .playback || speechViewModel.audioSession.categoryOptions.rawValue != 3 {
            speechViewModel.setupAudioSession()
            
        }
        ///create a speech utterance instance from utterance string
        let thisUttarance = AVSpeechUtterance(string: utterance)
        thisUttarance.pitchMultiplier = 1.0
        
        
        DispatchQueue.main.async {
       ///making sure the audio session is set the a given category and options
            if speechViewModel.audioSession.category == .playback && speechViewModel.audioSession.categoryOptions.rawValue == 3 {
                
                ///command synthesizer to speak the utterance
                speechViewModel.synthesizer.speak(thisUttarance)
            }
            ///if audio session is not configured.
            else {
                ///setup the audio session
                speechViewModel.setupAudioSession()
                ///command the synthesizer to speak.
                DispatchQueue.main.async {
                    speechViewModel.synthesizer.speak(thisUttarance)
                }
            }
        }
    }
    
    ///function to determine the exit range for the given step based on it's initial distance from the user.
    func nextStepRange(distance: String) -> Double {
        ///get the step distance in number format
        let thisStepDistance = getDistanceInNumber(distance: distance)
        ///if the distance is not 0
        if thisStepDistance != 0 {
            if let sign = directionSign {
                if sign.contains("arcade.stick") {
                   // return 30
                }
            }
            ///switch case statements
            switch thisStepDistance {
                ///if distance is between 0-79
            case 0...79:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 50 m range
                    return 50
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 40 m range
                    return 40
                }
                ///if speed of travel is less than 60 km/h
                else {
                    ///return 30 m range
                    return 30
                }
                ///if distance is between 79-99
            case 79...99:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 60 m range
                    return 60
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 50 m range
                    return 50
                }
                ///if speed of travel is less than 40 km/h
                else {
                    ///return 40 m range
                    return 40
                }
                ///if distance is between 100-199
            case 100...199:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 80 m range
                    return 80
                }
                ///if speed of travel is between 50-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 50 {
                    ///return 40 m range
                    return 60
                }
                ///if speed of travel is less than 50 km/h
                else {
                    ///return 50 m range
                    return 50
                }
                ///if distance is between 200-300
            case 200...300:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 160 m range
                    return 160
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 50 {
                    ///return 120 m range
                    return 120
                }
                ///if speed of travel is less than 50 km/h
                else {
                    ///return 80 m range
                    return 80
                }
                ///if distance is between 301-500
            case 301...500:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 260 m range
                    return 260
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 120 m range
                    return 120
                }
                ///if speed of travel is less than 40 km/h
                else {
                    ///return 80 m range
                    return 80
                }
                ///if distance is between 501-1000
            case 501...1000:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 400 m range
                    return 400
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 120 m range
                    return 120
                }
                ///if speed of travel is less than 40 km/h
                else {
                    ///return 80 m range
                    return 80
                }
                ///if distance is between 1001-10000
            case 1001...10000:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 400 m range
                    return 400
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 120 m range
                    return 120
                }
                ///if speed of travel is less than 40 km/h
                else {
                    ///return 80 m range
                    return 80
                }
                ///if distance is above 10000
            default:
                ///if speed of travel is more than 80 km/h
                if locationDataManager.speed >= 80 {
                    ///return 400 m range
                    return 400
                }
                ///if speed of travel is between 40-80 km/h
                else if locationDataManager.speed < 80 && locationDataManager.speed >= 40 {
                    ///return 120 m range
                    return 120
                }
                ///if speed of travel is less than 40 km/h
                else {
                    ///return 80 m range
                    return  80
                }
            }
        }
        return 200
    }
    
    ///function to get distance from the next step in numbers
    func getDistanceInNumber(distance: String) -> Double {      
        ///create a local step distance variable
        var thisStepDistance = 0.0
        ///if distance unit is set to miles.
        if MapViewAPI.distanceUnit == .miles {
            ///if distance is in miles
            if distance.contains("mi") {
                ///split the step distance string by space
                let stepDistanceSplits = distance.split(separator: " ")
                ///get the first splited text from an array of splits, which represents step distance
                let stepDistanceText = String(stepDistanceSplits[0])
                ///convert string formated distance to number
                if let dist = Double(stepDistanceText) {
                    ///convert miles to meters
                    thisStepDistance = dist * 1609
                }
            }
            ///if distance is in feet
            else {
                ///split the step distance string by space
                let stepDistanceSplits = distance.split(separator: " ")
                ///get the first splited text from an array of splits, which represents step distance
                let stepDistanceText = String(stepDistanceSplits[0])
                ///convert string formated distance to number
                if let dist = Double(stepDistanceText) {
                    ///assign the value to local variable in meters
                    thisStepDistance = dist / 3.281
                }
            }
        }
        else {
            ///if distance is in km
            if distance.contains("km") {
                ///split the step distance string by space
                let stepDistanceSplits = distance.split(separator: " ")
                ///get the first splited text from an array of splits, which represents step distance
                let stepDistanceText = String(stepDistanceSplits[0])
                ///convert string formated distance to number
                if let dist = Double(stepDistanceText) {
                    ///convert km to meters
                    thisStepDistance = dist * 1000
                }
            }
            ///if distance is in meters.
            else {
                ///split the step distance string by space
                let stepDistanceSplits = distance.split(separator: " ")
                ///get the first splited text from an array of splits, which represents step distance
                let stepDistanceText = String(stepDistanceSplits[0])
                ///convert string formated distance to number
                if let dist = Double(stepDistanceText) {
                    ///assign the value to local variable
                    thisStepDistance = dist
                }
            }
        }
        ///return the converted distance
        return thisStepDistance
    }
    
    func prepareForVoiceNavigation() {
        if speechViewModel.isMuted {
            speechViewModel.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            return
        }
        ///flag the step as not exited yet
        isStepExited = false
        ///set the utteranceDistance by the updated next step distance on appear of instruction text
        utteranceDistance = getUtteranceDistance()
        ///get the range preset from the utteranceDistance received on first appearance of the instruction.
        maxDistance = nextStepDistance
        if getDistanceInNumber(distance: nextStepDistance) < 80 && locationDataManager.speed > 36 {
            return
        }
        ///start voice navigation with the utterance.
        if directionSign == "arcade.stick" {
            startVoiceNavigation(with: "In \(utteranceDistance), \(instruction), will arrive.")
        }
        else if directionSign == "arcade.stick.and.arrow.right"  {
            startVoiceNavigation(with: "In \(utteranceDistance), \(instruction), will be on your right.")
        }
        else if directionSign == "arcade.stick.and.arrow.left" {
            startVoiceNavigation(with: "In \(utteranceDistance), \(instruction), will be on your left.")
        }
        else if directionSign == "exclamationmark.triangle" {
            startVoiceNavigation(with: "\(instruction)")
        }
       ///if direction sign is other then mentioned above.
        else {
            ///if utterance distance is less than or equal to 50
            if getDistanceInNumber(distance: utteranceDistance) <= 50 {
                ///start voice navigation with no inital text instruction
                startVoiceNavigation(with: "\(instruction)")
            }
            ///else if distance is above 50.
            else {
                ///start voice navigation with inital text instruction
                startVoiceNavigation(with: "In \(utteranceDistance), \(instruction)")
            }
        }
    }
    
    func alertUserWithVoiceNavigation() {
        if speechViewModel.isMuted {
            speechViewModel.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            return
        }
        ///get the range for starting voice instruction from max step distance received.
        range = nextStepRange(distance: maxDistance)
        ///get the current distance from user to the next step in number format
        let distance = getDistanceInNumber(distance: nextStepDistance)
        ///if the distance is less than or equal to the range and step is not exited yet, prepare for the voice navigation
        if distance <= range && !isStepExited {
            ///if direction sign has no arrow
            if directionSign == "arcade.stick" {
                ///append the instruction with is arrived string and start voice navigation
                startVoiceNavigation(with: "\(instruction), is arrived.")
            }
            ///if the direction sign has an arrow pointing to the right
            else if directionSign == "arcade.stick.and.arrow.right"  {
                ///append instruction with is on your right string and start voice navigation.
                startVoiceNavigation(with: "\(instruction), is on your right.")
            }
            ///if the direction sign has an arrow pointing to the leftt
            else if directionSign == "arcade.stick.and.arrow.left" {
                ///append instruction with is on your left string and start voice navigation.
                startVoiceNavigation(with: "\(instruction), is on your left.")
            }
            else {
                ///if the direction sign has no arcade stick then don't append any string and start voice navigation.
                startVoiceNavigation(with:"\(instruction)")
            }
            ///flag the step as exited upon entering to the step range and finishing voice navigation.
            isStepExited = true
        }
    }
    
    ///method to get utterance distance for speech.
    func getUtteranceDistance() -> String {
        ///get the distance numbers from string distance
        var distanceNumbers = getDistanceInNumber(distance: nextStepDistance)
        ///if distance unit set is in miles
        if MapViewAPI.distanceUnit == .miles {
            ///get the nextsetp distance string as utterance distance
            ///if step instruction distance is containing km sign.
            if nextStepDistance.contains("mi") {
                ///convert distance from meters to km
                distanceNumbers = distanceNumbers/1609
                if distanceNumbers > 1.0 {
                    ///round up the double to whole number
                    let roundedDistance = round((distanceNumbers * 10.0) / 5) * 0.5
                    ///convert whole double to integer
                    if abs(roundedDistance - Double(Int(roundedDistance))) != 0.5 {
                        let wholeDistance = Int(roundedDistance)
                        return String(wholeDistance) + " mi"
                    }
                    else {
                        let wholeDistance = roundedDistance
                        return String(wholeDistance) + " mi"
                    }
                }
                else {
                    return String(format: "%.1f", distanceNumbers) + " mi"
                }
            }
            ///if step instruction distance is not containing km sign.
            else {
                distanceNumbers = distanceNumbers * 3.281
                let roundedDistance = round(distanceNumbers/50) * 50.0
                let wholeDistance = Int(roundedDistance)
                return String(wholeDistance) + " ft"
            }
        }
        else {
            ///if step instruction distance is containing km sign.
            if nextStepDistance.contains("km") {
                ///convert distance from meters to km
                distanceNumbers = distanceNumbers/1000
                ///round up the double to whole number
                let roundedDistance = round((distanceNumbers * 10.0) / 5) * 0.5
                ///convert whole double to integer
                if abs(roundedDistance - Double(Int(roundedDistance))) != 0.5 {
                    let wholeDistance = Int(roundedDistance)
                    return String(wholeDistance) + " km"
                }
                else {
                    let wholeDistance = roundedDistance
                    return String(wholeDistance) + " km"
                }
            }
            ///if step instruction distance is not containing km sign.
            else {
                let roundedDistance = round(distanceNumbers/50) * 50.0
                let wholeDistance = Int(roundedDistance)
                return String(wholeDistance) + " m"
            }
        }
    }
}

#Preview {
    DirectionHeaderView(directionSign: "", nextStepDistance: "", instruction: "", showDirectionsList: .constant(false), height: .constant(0), locationDataManager: LocationDataManager(), speechViewModel: SpeechViewModel())
}
