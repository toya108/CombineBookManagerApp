//
//  DateExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/29.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

extension Date {
    /// カレンダーのデフォルトを日本仕様にします。
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: TimeZoneIdentifier.tokyo.rawValue)!
        calendar.locale   = Locale(identifier: LocaleIdentifier.jp.rawValue)
        return calendar
    }
    
    /// フォーマット指定で日付を文字列に変換します。
    /// - note: パラメーター無しの場合は"yyyy-MM-dd"になります。
    /// - Parameter format: フォーマット
    /// - Returns: 日付の文字列
    func convertString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
