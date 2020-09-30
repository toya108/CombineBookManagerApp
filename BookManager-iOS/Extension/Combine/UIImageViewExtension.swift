//
//  UIImageViewExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine
import Foundation

extension UIImageView {
    /// 画像がセットされた時にBase64文字列を発行するPublisher
    var base64ImagePublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: .didSetImageIntoImageView, object: nil)
            .compactMap { $0.userInfo?["base64Image"] as? String }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
