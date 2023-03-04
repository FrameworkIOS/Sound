//
//  File.swift
//  
//
//  Created by eCOM-Elango.a on 04/03/23.
//

import Foundation

extension Sound {
    public enum SoundError: Error {
        case notFound(String)
        case couldNotPlay(String)
    }
    
    func handle(error: Error) {
        if let error = error as? SoundError {
            switch error {
            case .notFound(let name):
                print("Sound not found \(name)")
            case .couldNotPlay(let name):
                print("Sound could not able able to play \(name)")
            } else {
                let error = error as NSError
                print("""
                    Sound encountered a serious issue!
                    
                """)
            }
        }
    }
}
