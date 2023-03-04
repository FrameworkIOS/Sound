//
//  File.swift
//  
//
//  Created by Krisna Pranav on 04/03/23.
//
import Foundation

@available(iOS 10.0, *)
extension Sound {
    public enum Note {
        case sound(Audio)
        
        case vibration(Vibration)
        
        case tapticEngine(TapticEngine)
        
        case hapticFeedback(HapticFeedback)
        
        case waitUntilFinished
        
        case wait(TimeInterval)
    }
}
