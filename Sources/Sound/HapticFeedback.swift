//
//  File.swift
//  
//
//  Created by eCOM-Elango.a on 04/03/23.
//

import Foundation

@available(iOS 10.0, *)
extension Sound {
    public enum HapticFeedback {
        case notification(Notification)
        public enum Notification {
            case success
            case warning
            case failure
        }
        
        case impact(Impact)
        public enum Impact {
            case light
            case medium
            case heavy
        }
        
        case selection
    }
}
