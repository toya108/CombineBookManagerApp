//
//  UIViewControllerExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/31.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// 現在フォーカスしているViewを探索して取得します。
    /// - Parameter view: 探索対象のView
    /// - Returns: FirstResponder
    func getFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        return view.subviews.lazy.compactMap { self.getFirstResponder(view: $0) }.first
    }
    
    /// OKボタンのみのアラートを表示します。
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    ///   - okActionHandler: OKタップ時のアクション
    func showOkAlert(title: String, message: String, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: okActionHandler)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    /// アラートを生成します。
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    ///   - actions: アラートアクション
    func showAlert(title: String, message: String, actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}
