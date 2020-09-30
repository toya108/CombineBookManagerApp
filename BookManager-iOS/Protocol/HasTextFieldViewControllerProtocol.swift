//
//  HasTextFieldViewControllerProtocol.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/02.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import UIKit

/// TextFieldを持つViewontrollerが準拠するプロトコル
protocol HasTextFieldViewControllerProtocol: UIViewController {
    var observedTokens: [NotificationToken] { get set }
}

extension HasTextFieldViewControllerProtocol {
    
    /// キーボードを表示する時のNotificationToken
    var keyboardWillShowToken: NotificationToken {
        return NotificationCenter.default.observe(name: UIResponder.keyboardWillShowNotification,
                                                  object: nil,
                                                  queue: nil,
                                                  using: { [weak self] notification in
                                                    
                                                    guard let self = self else { return }
                                                    
                                                    self.transitionViewIfNeeded(notification: notification as NSNotification) })
    }
    
    /// キーボードが隠れる時のNotificationToken
    var keyboardWillHideToken: NotificationToken {
        return NotificationCenter.default.observe(name: UIResponder.keyboardWillHideNotification,
                                                  object: nil,
                                                  queue: nil,
                                                  using: { [weak self] notification in
                                                    
                                                    guard let self = self else { return }
                                                    
                                                    self.resetViewPositionIfNeeded(notification: notification as NSNotification) })
    }
    
    /// キーボードが表示された際にTextFieldと被っていたらViewを遷移させます。
    /// - Parameter notification: keyboardWillShowNotification
    func transitionViewIfNeeded(notification: NSNotification) {
        
        guard case let keyboardFrameUserInfo as NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
        
        let keyboardHeight = keyboardFrameUserInfo.cgRectValue.height
        
        guard case let editingTextField as UITextField = getFirstResponder(view: view) else { return }
        
        guard let superView = editingTextField.superview else { return }
        
        // textFieldの親ViewがcontentView以外の場合、画面上部からのy座標が正しく取得できないのでcontentViewを基準にframeをconvertします。
        let textFieldFrame = superView.isEqual(view) ? editingTextField.frame : editingTextField.convert(editingTextField.frame, to: view)
        let marginFromTextFieldToViewBottom = view.frame.height - (textFieldFrame.origin.y + textFieldFrame.height)
        
        let coverdMargin = keyboardHeight - marginFromTextFieldToViewBottom
        
        guard case let duration as TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] else { return }
        
        let isCoverd = coverdMargin >= 0
        
        switch (view.isFirstPosition, isCoverd) {
        case (_, true): view.changePotision(duration: duration, x: 0, y: -(coverdMargin + 16))
        case (true, false): break
        case (false, false): view.resetPositonIfNeeded(duration: duration)
        }
    }
    
    /// キーボードが閉じられる際にViewの位置をリセットします。
    /// - Parameter notification: keyboardWillHideNotification
    func resetViewPositionIfNeeded(notification: NSNotification) {
        
        guard case let duration as TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] else { return }
        
        view.resetPositonIfNeeded(duration: duration)
    }
    
    /// 検証結果の配列から全ての結果が有効だったかどうか判定して返します。
    /// - Parameter results: 検証結果の配列
    /// - Returns: 全て有効だったかどうか
    func isValidationSucceed(by results: [ValidationResult]) -> Bool {
        return results.allSatisfy { result -> Bool in
            
            switch result {
            case .valid: return true
            case .invalid: return false }
        }
    }
    
    /// 検証結果のエラーメッセージから文字列の配列を生成します。
    /// - Parameter results: 検証結果
    /// - Returns: メッセージ
    
    func generateErrorMessage(by errors: [ValidationError]) -> String {
        
        var messages = [String]()
        
        errors.forEach { messages.append($0.description) }
        
        return messages.joined(separator: "\n")
    }
}
