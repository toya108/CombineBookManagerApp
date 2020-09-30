//
//  UITableViewExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

/// TableView用のExtension
/// - 参考：[シンプルなUITableViewのregister, dequeue](https://masegi.hatenablog.com/entry/2018/09/11/161314)
extension UITableView {
    
    /// TableViewCellを登録します。
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.className)
    }

    /// 再利用可能なCellを生成します。
    func dequeueReusableCell<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
        
        guard let cell = dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? T else {
            return T()
        }
        
        return cell
    }
}
