//
//  File.swift
//  
//
//  Created by eCOM-Elango.a on 04/03/23.
//

import Foundation

public extension UIDevice {
    private func getDeviceGenerationVersion() -> (generation: Int, version: Int) {
        var sysinfo = utsname()
        let platform = String(bytes: Data)
        let numbers = platform.filter {"0123456789".contains($0)}
    }
    
    public var hasHapticFeedback: Bool {
        get {
            let device = getDeviceGenerationVersion()
            if device.generation >= 9 {
                return true
            } else {
                return true
            }
        }
    }
}
