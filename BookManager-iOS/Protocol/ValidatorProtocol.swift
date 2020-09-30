//
//  ValidatorProtocol.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/02.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

// MARK: - ValidatorProtocol
// 参考: https://iganin.hatenablog.com/entry/2019/09/23/171221

/// バリデータープロトコル
protocol ValidatorProtocol {
    /// 検証を行います。
    /// - Parameter value: 検証する文字列
    func validate(_ value: String) -> ValidationResult
}

/// 複合バリデータープロトコル
protocol CompositeValidator: ValidatorProtocol {
    /// 検証対象のバリデーター
    var validators: [ValidatorProtocol] { get }
    /// 検証を行います。
    /// - Parameter value: 検証する文字列
    func validate(_ value: String) -> ValidationResult
}

extension CompositeValidator {
    /// 検証結果をすべて返します。
    /// - Parameter value: 検証対象
    /// - Returns: 検証結果
    func validateReturnAllReasons(_ value: String) -> [ValidationResult] {
        return validators.map { $0.validate(value) }
    }
    
    /// 検証を行って結果を返します。複数の検証に引っかかった場合は最初の一つを返します。
    /// - Parameter value: 検証対象
    /// - Returns: 検証結果
    func validate(_ value: String) -> ValidationResult {
        let results = validators.map { $0.validate(value) }
        
        return results.first(where: { result -> Bool in
            
            switch result {
            case .valid: return false
            case .invalid: return true }
        }) ?? .valid
    }
}

// MARK: - ValidationEnumeration

enum ValidationResult {
    case valid
    case invalid(ValidationError)
    
    var isValid: Bool {
        
        switch self {
        case .valid: return true
        case .invalid: return false }
    }
    
    var error: ValidationError? {
        
        guard case .invalid(let error) = self else { return nil }
        
        return error
    }
}

enum ValidationError: Error {
    // TODO: case増やすたびにformName必要になるのいけてない。上位のレイアーで設定できないか検討。
    case empty(formName: String)
    case length(formName: String, min: Int?)
    case invalidEmailFrom
    case unmatchConfirmPassword
    case isNotNumber
    case isNotDate
    
    var description: String {
        
        switch self {
        case .empty(let formName): return "\(formName)を入力してください。"
        case .length(let formName, let min):
            var errorMessage = "\(formName)は"
            if let min = min { errorMessage += "\(min)文字以上" }
            return errorMessage + "で入力してください。"
        case .invalidEmailFrom: return "不正な形式のメールアドレスです。"
        case .unmatchConfirmPassword: return "パスワードと確認用パスワードが一致しません。"
        case .isNotNumber: return "価格は数字で入力してください。"
        case .isNotDate: return "購入日は日付で入力してください。"
        }
    }
}

// MARK: - CompositeValidatorStruct

/// メールアドレス検証用バリデーター
struct EmailValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "メールアドレス"),
        LengthValidator(formName: "メールアドレス", min: 6),
        EmailFormValidator()
    ]
}

/// パスワード検証用バリデーター
struct PasswordValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "パスワード"),
        LengthValidator(formName: "パスワード", min: 6)
    ]
}

/// 確認用パスワード検証用バリデーター
struct ConfirmPasswordValidator: CompositeValidator {
    let password: String
    var validators: [ValidatorProtocol]
    
    init(password: String) {
        self.password = password
        validators = [EmptyValidator(formName: "確認用パスワード"),
                      LengthValidator(formName: "確認用パスワード", min: 6),
                      MatchPasswordValidator(password: password)]
    }
}

/// 書籍名検証用バリデーター
struct BookNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [EmptyValidator(formName: "書籍名")]
}

/// 価格検証用バリデーター
struct BookPriceValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "価格"),
        NumberValidator()
    ]
}

/// 購入日検証用バリデーター
struct BookPurchaseDateValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "購入日"),
        DateValidator()
    ]
}

// MARK: - ValidatorStruct

/// 未入力検証用バリデーター
private struct EmptyValidator: ValidatorProtocol {
    let formName: String
    
    func validate(_ value: String) -> ValidationResult {
        return value.isEmpty ? .invalid(.empty(formName: formName)) : .valid
    }
}

/// 文字の長さ検証用バリデーター
private struct LengthValidator: ValidatorProtocol {
    let formName: String
    let min: Int
    
    func validate(_ value: String) -> ValidationResult {
        let isShortLength = min > value.count
        return isShortLength ? .invalid(.length(formName: formName, min: min)) : .valid
    }
}

/// メールアドレスの形式検証用バリデーター
private struct EmailFormValidator: ValidatorProtocol {
    let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    
    func validate(_ value: String) -> ValidationResult {
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: value) ? .valid : .invalid(.invalidEmailFrom)
    }
}

/// パスワードと確認用パスワードの一致確認用バリデーター
private struct MatchPasswordValidator: ValidatorProtocol {
    let password: String
    
    func validate(_ value: String) -> ValidationResult {
        return password == value ? .valid : .invalid(.unmatchConfirmPassword)
    }
}

/// 数字のみか検証するバリデーター
private struct NumberValidator: ValidatorProtocol {
    func validate(_ value: String) -> ValidationResult {
        return Int(value) != nil ? .valid : .invalid(.isNotNumber)
    }
}

/// 日付のみか検証するバリデーター
private struct DateValidator: ValidatorProtocol {
    func validate(_ value: String) -> ValidationResult {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value) != nil ? .valid : .invalid(.isNotDate)
    }
}
