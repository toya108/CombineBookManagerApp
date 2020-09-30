//
//  NotificationCenterExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/01.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    /// NotificationCenterに通知を登録して通知removeObserver用のインスタンスを返します。
    /// - Parameters:
    ///   - name: NotifiationName
    ///   - obj: 通知を受け取るオブジェクト
    ///   - queue: キュー
    ///   - block: 通知時に実行するブロック
    /// - Returns: removeObserver用インスタンス
    func observe(name: NSNotification.Name?,
                 object obj: Any?,
                 queue: OperationQueue?,
                 using block: @escaping (Notification) -> Void ) -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}

/// Notificationenterと登録するブロックをまとめてラップするクラス
/// - note: NotificationCenterにusingでブロックを登録すると自動でremoveObserverを呼んでくれなくなります。
///         そのため、deinitの際にremoveObserverを走らすためのラッパークラスを用意しています。
///         参考：https://oleb.net/blog/2018/01/notificationcenter-removeobserver/
final class NotificationToken: NSObject {
    /// 通知対象のNotificationCenter
    let notificationCenter: NotificationCenter
    /// 通知時に実行するobserver
    let token: Any
    
    /// initializer
    /// - Parameters:
    ///   - notificationCenter: 通知を登録したNotifaicationCenrer
    ///   - token: remove対象observer
    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    /// 参照が破棄される際に通知を削除します。
    deinit {
        notificationCenter.removeObserver(token)
    }
}
