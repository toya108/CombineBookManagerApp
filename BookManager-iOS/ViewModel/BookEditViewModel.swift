//
//  BookEditViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/04.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine

/// 書籍編集画面用ViewModel
final class BookEditViewModel: ViewModelProtocol {
    
    typealias request = Request.BookEdit
    
    // MARK: Properties

    /// 書籍のデータ
    var book: Book
    
    private var binding = Set<AnyCancellable>()

    @Published private(set) var networkState: NetWorkState = .standby
    
    // MARK: Initializers

    init(book: Book) {
        self.book = book
    }
    
    // MARK: Internal Functions

    /// 書籍のバリデーションが有効化チェックします。
    /// - Returns: 全て有効ならtrueを返します。
    func validateBook() -> Bool {
        let validationResults = [BookNameValidator().validate(book.name),
                                 BookPriceValidator().validate(book.price ?? ""),
                                 BookPurchaseDateValidator().validate(book.purchaseDate ?? "")]
        return validationResults.allSatisfy { $0.isValid }
    }

    /// 書籍のバリデーションのエラーを返します。
    /// - Returns: エラー
    func extractBookEditValidationErrors() -> [ValidationError] {
        let validationResults = [BookNameValidator().validate(book.name),
                                 BookPriceValidator().validate(book.price ?? ""),
                                 BookPurchaseDateValidator().validate(book.purchaseDate ?? "")]
        return validationResults.filter({ !$0.isValid }).compactMap { $0.error }
    }
    
    /// 書籍を編集します。
    func bookEdit() {
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
                .makeDataTaskPublisher(from: request(id: book.id,
                                                     headers: [header(headerField: "access_token", value: token)],
                                                     params: params))
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
