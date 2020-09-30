//
//  StringExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation


extension String {
    
    /// 文字列を日付に変換します。
    /// - Parameter format: 変換用フォーマット
    /// - Returns: 変換した日付(変換に失敗したらnilを返します。)
    func convertDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        
        guard let date = formatter.date(from: self) else {
            assertionFailure("日付の変換に失敗しました。")
            return nil
        }
        
        return date
    }
}
