//
//  UIImageExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

extension UIImage {
    /// UIImageをbase64文字列に変換します。
    /// - Returns: Base64文字列
    func convertBase64String() -> String {
        
        guard case let imageData as NSData = pngData() else { return "" }
        
        let data = imageData.base64EncodedString(options: .lineLength64Characters)
        return data
    }
}
