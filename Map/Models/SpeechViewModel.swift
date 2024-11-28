//
//  SpeachViewModel.swift
//  Map
//
//  Created by saj panchal on 2024-11-12.
//

import AVFoundation

///SpeechViewModel class is an observable object that is also a delegate to AVSpeechSynthesizer (part of Objective-C class hierarchy)
class SpeechViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    ///bool variable to detect if synthesizer is currently speaking or not
    @Published var isSpeaking = false
    ///bool variable to detect if synthesizer has finished speaking or not.
    @Published var isFinished = false
    ///AVAudioSession Instance to create or destroy the audio session
    var audioSession = AVAudioSession.sharedInstance()
    ///AVSpeechSynthesizer object to speak, pause, stop utterances.
    var synthesizer = AVSpeechSynthesizer()
    
    ///override the parent class initializer
    override init() {
        ///initialize the parent class
        super.init()
        ///set SpeechViewModlel object as synthesizer's delegate
        synthesizer.delegate = self
        ///call setupAudioSession method to setup the audio session.
        self.setupAudioSession()
    }
///deinitializer
    deinit {
            do {
                try self.audioSession.setActive(false)
            }
            catch {
                print("error:\(error.localizedDescription)")
            }
        synthesizer.delegate = nil
    }
    
///method to make synthesizer to speak the utterances.
    func speak(_ utterance: AVSpeechUtterance) {
        ///call the speak method of AVSpeechSynthesizer object to speak utterances.
        self.synthesizer.speak(utterance)
    }
    
    ///method to setup the audio session
    func setupAudioSession() {
        DispatchQueue.main.async {
            do {
                if self.audioSession.category != .playback || self.audioSession.categoryOptions.rawValue != 3 {
                    ///call AVAudioSession setCategory method to set audio category as playback and options as duckOthers to reduce the volume of other audio sources.
                    try self.audioSession.setCategory(.playback,  options: .duckOthers)
                }
                ///activate the audio session.
                try self.audioSession.setActive(true)
            }
            catch {
                print("error:\(error.localizedDescription)")
            }
        }
        
    }
    
    ///method to reset the audioSession
    func resetAudioSession() {
        ///call a method stopSpeaking from AVSpeechSynthesizer to stop synthesizer speaking immidiately.
        self.synthesizer.stopSpeaking(at: .immediate)
        ///this code will be executed with 2 secs of delay.
       DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
        do {
            if !self.isSpeaking {
                try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
            catch {
                print("error:\(error.localizedDescription)")
            }
        }
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.isSpeaking = true
        self.isFinished = false
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        self.isFinished = true
        self.resetAudioSession()
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        self.isFinished = false
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        self.isFinished = false
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        self.isFinished = false
        self.isSpeaking = true
    }
   
}
