//
//  BookAddViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine

/// 書籍追加画面用ViewModel
final class BookAddViewModel: ViewModelProtocol {
    
    typealias request = Request.BookAdd
    
    // MARK: Properties

    /// 書籍のデータ(書籍追加にidは不要なので-1で初期化しています。リクエストの際には利用しないでください。) 
    var book: Book = Book(id: -1, name: "", image: "", price: "", purchaseDate: "")
    
    private var binding = Set<AnyCancellable>()
    @Published private(set) var networkState: NetWorkState = .standby

    // MARK: Internal Functions

    /// 書籍のバリデーションが有効化チェックします。
    /// - Returns: 全て有効ならtrueを返します。
    func validateBook() -> Bool {
        let validationResults = [BookNameValidator().validate(book.name),
                                 BookPriceValidator().validate(book.price ?? ""),
                                 BookPurchaseDateValidator().validate(book.purchaseDate ?? "")]
        return validationResults.allSatisfy { $0.isValid }
    }
    
    /// ログインバリデーションのエラーを返します。
    /// - Returns: エラー
    func extractBookEditValidationErrors() -> [ValidationError] {
        let validationResults = [BookNameValidator().validate(book.name),
                                 BookPriceValidator().validate(book.price ?? ""),
                                 BookPurchaseDateValidator().validate(book.purchaseDate ?? "")]
        return validationResults.filter({ !$0.isValid }).compactMap { $0.error }
    }
    
    /// 書籍を登録します。
    func bookAdd() {
        networkState = .loading
        
        let receiveCompletionHandler: (Subscribers.Completion<APIError>) -> Void = { [weak self] completion in
            
            guard let self = self else { return }
            
            switch completion {
            case .failure(let error): self.networkState = .error(error)
            case .finished: self.networkState = .finished
            }
        }
        
        do {
            let params = request.Parameters(name: book.name, image: book.image, price: Int(book.price!), purchaseDate: book.purchaseDate)
            guard let token = try KeychainManager.keychain.get("token") else {
                throw NSError(domain: "", code: 0)
            }
            
            try APIClient()
                .makeDataTaskPublisher(from: request(headers: [header(headerField: "access_token", value: token)], params: params))
                .sink(receiveCompletion: receiveCompletionHandler, receiveValue: {_ in })
                .store(in: &binding)
        } catch APIError.urlEncode {
            networkState = .error(APIError.urlEncode)
        } catch APIError.jsonEncode {
            networkState = .error(APIError.jsonEncode)
        } catch {
            assertionFailure("想定外のエラーです。")
            return
        }
    }
}
