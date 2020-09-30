//
//  NukeManager.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Nuke
import UIKit

/// Nuke操作用マネージャークラス
struct NukeManager {
    /// 画像ロードオプション
    private static let options = ImageLoadingOptions(placeholder: UIImage(named: "loading"),
                                                     failureImage: UIImage(named: "画像の読み込みに失敗しました。"))
    
    /// 画像をロードします。
    /// - Parameters:
    ///   - urlString: urlの文字列
    ///   - imageView: ロードした画像をセットするimageView
    static func loadImage(with urlString: String, imageView: UIImageView) {
        
        guard let url = URL(string: urlString) else { return }
        
        Nuke.loadImage(with: url, options: options, into: imageView)
    }
    
    /// 画像をロードしてNotificationCenterへの通知を行います。
    /// - Parameters:
    ///   - urlString: urlの文字列
    ///   - imageView: ロードした画像をセットするimageView
    static func loadImageWithNotificationPost(with urlString: String, imageView: UIImageView) {
        
        guard let url = URL(string: urlString) else { return }
        
        Nuke.loadImage(with: url, options: options, into: imageView, completion: { completion in
            if case .success(let response) = completion {
                NotificationCenter.default.post(name: .didSetImageIntoImageView,
                                                object: nil,
                                                userInfo: ["base64Image": response.image.convertBase64String()])
            }
        })
    }
}
