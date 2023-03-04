//
//  File.swift
//  
//
//  Created by Krisna Pranav on 04/03/23.
//

import Foundation

@available(iOS 10.0, *)
extension Sound {
    public enum Audio {
        case asset(name: String)
        case file(name: String, extension: String)
        case url(URL)
        case system(SystemSound)
    }
}
