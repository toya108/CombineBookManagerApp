//
//  BookRowTableViewCell.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Nuke

/// 書籍一覧TableView用Cell
final class BookRowTableViewCell: UITableViewCell {
    
    /// 書籍追加画面の定数の構造体
    private struct Constant {
        static let cellHeightConstant: CGFloat = 100
        static let bookImageViewLeftConstant: CGFloat = 8
        static let bookImageViewTopCostant: CGFloat = 8
        static let bookImageViewButtomConstant: CGFloat = -8
        static let bookImageViewWidthConstant: CGFloat = 100
        static let bookNameLabelLeftConstant: CGFloat = 8
        static let bookPurchaseDateLabelRightConstant: CGFloat = -8
    }
    
    // MARK: Properties
    
    private lazy var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var bookNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 // 改行を許可するため
        return label
    }()
    
    private lazy var bookPriceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var bookPurchaseDateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier )
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Internal Functions
    
    /// cellに書籍のデータをセットします。
    /// - Parameter book: 書籍
    func setContents(book: Response.Book) {
        
        if let imageURL = book.image {
            NukeManager.loadImage(with: imageURL, imageView: bookImageView)
        }
        
        bookNameLabel.text = book.name
        bookPriceLabel.text = book.price?.description
        bookPurchaseDateLabel.text = book.purchaseDate
    }
    
    // MARK: Private Functions

    /// 共通初期化処理
    private func commonInit() {
        contentView.heightAnchor.constraint(equalToConstant: Constant.cellHeightConstant).isActive = true
        accessoryType = .disclosureIndicator
        
        addSubViews()
        addConstraints()
    }
    
    /// addSubViewします。
    private func addSubViews() {
        [bookImageView, bookNameLabel, bookPriceLabel, bookPurchaseDateLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// 各SubViewに制約を追加します。
    private func addConstraints() {
        let bookImageViewConstraints = [
            bookImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Constant.bookImageViewLeftConstant),
            bookImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constant.bookImageViewTopCostant),
            bookImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constant.bookImageViewButtomConstant),
            bookImageView.widthAnchor.constraint(equalToConstant: Constant.bookImageViewWidthConstant)
        ]
        
        let bookNameLabelConstraints = [
            bookNameLabel.leftAnchor.constraint(equalTo: bookImageView.rightAnchor, constant: Constant.bookNameLabelLeftConstant),
            bookNameLabel.topAnchor.constraint(equalTo: bookImageView.topAnchor)
        ]
        
        let bookPriceLabelConstraints = [
            bookPriceLabel.leftAnchor.constraint(equalTo: bookNameLabel.leftAnchor),
            bookPriceLabel.bottomAnchor.constraint(equalTo: bookImageView.bottomAnchor)
        ]
        
        let bookPurchaseLableConstraints = [
            bookPurchaseDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: Constant.bookPurchaseDateLabelRightConstant),
            bookPurchaseDateLabel.bottomAnchor.constraint(equalTo: bookImageView.bottomAnchor)
        ]
        
        [bookImageViewConstraints, bookNameLabelConstraints, bookPriceLabelConstraints, bookPurchaseLableConstraints]
            .forEach(NSLayoutConstraint.activate(_:))
    }
}
