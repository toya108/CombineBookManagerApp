//
//  KeychainManager.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/23.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import KeychainAccess

struct KeychainManager {
    
    static var keychain: Keychain {
        guard let identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String else { return Keychain(service: "") }
        return Keychain(service: identifier)
    }
    
}
