//
//  FetchClassNameExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

/// クラス名取得用プロトコル
/// - note: 参考：[使うと手放せなくなるSwift Extension集 (Swift 5版)](https://qiita.com/tattn/items/ff50e575bc149ecb8e80#%E3%82%AF%E3%83%A9%E3%82%B9%E5%90%8D%E3%81%AE%E5%8F%96%E5%BE%97)
protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

extension ClassNameProtocol {
    static var className: String {
        String(describing: self)
    }

    var className: String {
        Self.className
    }
}

// Objectに準拠させることでどのクラスでも使えるようにしています。
extension NSObject: ClassNameProtocol {}
