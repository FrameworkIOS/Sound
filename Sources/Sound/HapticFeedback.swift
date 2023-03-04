//
//  File.swift
//  
//
//  Created by eCOM-Elango.a on 04/03/23.
//

import Foundation

@available(iOS 10.0, *)
extension Sound {
    public enum HapticFeedbakc {
        case notification(Notification)
        public enum Notification {
            case success
            case warning
            case failure
        }
        
        case impac(Impact)
        
        public enum Impact {
            case light
            case heavy
        }
        
        case selection
    }
}
