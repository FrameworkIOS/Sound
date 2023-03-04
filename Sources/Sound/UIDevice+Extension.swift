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
        uname(&sysinfo)
        let platform = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        if platform.lowercased().prefix("iPhone".count) != "iPhone".lowercased() {  simulator)
            return (0, 0)
        }
        let numbers = platform.filter { "0123456789,".contains($0) }
        if let commaIndex = numbers.index(of: ",") {
            let firstNumber = numbers[numbers.startIndex..<commaIndex]
            let afterCommaIndex = numbers.index(after: commaIndex)
            let secondNumber = numbers[afterCommaIndex..<numbers.endIndex]
            let generation = Int(firstNumber) ?? 0
            let version = Int(secondNumber) ?? 0
            return (generation, version)
        } else {
            return (0, 0)
        }
    }
    
    public var hasTapticEngine: Bool {
        get {
            let device = getDeviceGenerationVersion()
            if device.generation == 8 {
                if device.version == 4 {
                    return false
                } else {
                    return true
                }
            } else if device.generation > 8 {
                return true
            } else {
                return false
            }
        }
    }
    
    public var hasHapticFeedback: Bool {
        get {
            let device = getDeviceGenerationVersion()
            if device.generation >= 9 {
                return true
            } else {
                return false
            }
        }
    }
}
