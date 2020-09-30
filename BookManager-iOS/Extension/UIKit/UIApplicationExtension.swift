//
//  UIApplicationExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/29.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// 現在のKeyWindowを取得します。
    /// - Returns: KeyWindow
    func extractCurrentKeyWindow() -> UIWindow? {
        
        let activeScene = connectedScenes.first(where: { $0.activationState == .foregroundActive })
        
        guard case let windowScene as UIWindowScene = activeScene else { return nil }
        
        let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        return keyWindow
    }
}
