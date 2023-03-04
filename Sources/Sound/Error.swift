//
//  File.swift
//  
//
//  Created by Krisna Pranav on 04/03/23.
//
// The MIT License (MIT)
//

import Foundation

@available(iOS 10.0, *)
extension Sound {
    public enum SoundError: Error {
        case notFound(String)
        case couldNotPlay(String)
    }
    
    func handle(error: Error) {
        if let error = error as? SoundError {
            switch error {
            case .notFound(let name):
                print("♫ Sound could not find \(name)!")
            case .couldNotPlay(let name):
                print("♫ Sound could not play \(name)!")
            }
        } else {
            let error = error as NSError
            print("""
                ♫ Sound encountered a serious issue!!!!
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
}
