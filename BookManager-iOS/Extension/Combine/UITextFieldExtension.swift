//
//  UITextFieldExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/04.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import UIKit
import Combine

extension UITextField {
    /// テキストが変更された時に変更後の文字列を出力するPublisher
    var textDidChangedPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    /// 編集画終了した時に文字列を出力するPublisher
    /// 購入日TextFieldは
    var endEditingPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: UITextField.textDidEndEditingNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
