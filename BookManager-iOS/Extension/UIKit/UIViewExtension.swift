//
//  UIViewExtension.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/29.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Viewが初期位置にいるかどうかを返します。
    var isFirstPosition: Bool {
        return frame.origin.y.isZero
    }
    
    /// ViewをSafeAreaいっぱいに広げます。
    /// - Parameter safeArea: safeArea
    func fillSafeArea(safeArea: UILayoutGuide) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: safeArea.topAnchor),
            bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            rightAnchor.constraint(equalTo: safeArea.rightAnchor)
        ])
    }
    
    /// Viewのポジションが移動されていたらリセットします。
    /// - Parameter duration: 実行時間
    func resetPositonIfNeeded(duration: TimeInterval) {
        if isFirstPosition { return }
        
        UIView.animate(withDuration: duration) { [weak self] in
            
            guard let self = self else { return }
            
            self.transform = CGAffineTransform.identity
        }
    }
    
    /// Viewのポジションを動かします。
    /// - Parameters:
    ///   - duration: 実行時間
    ///   - x: x座標
    ///   - y: y座標
    func changePotision(duration: TimeInterval, x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: duration) { [weak self] in
            
            guard let self = self else { return }
            
            self.transform = CGAffineTransform(translationX: x, y: y)
        }
    }
}
