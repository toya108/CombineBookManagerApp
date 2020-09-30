//
//  BookListViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/04.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine

final class BookListViewModel: ViewModelProtocol {
    
    typealias request = Request.BookList
    
    // MARK: Properties
    
    var currentPage = 0
    var limit = 20
    
    private var binding = Set<AnyCancellable>()
    // 初回は必ずロードして欲しいので初期値を1にしています。
    private var totalPages = 1
    
    @Published private(set) var networkState: NetWorkState = .standby
    @Published private(set) var bookListResponnse: [Response.Book] = []
    
    // MARK: Initializers

    /// 初期化時に最初の20件を取得します。
    init() {
        fetchBookList()
    }
    
    // MARK: Internal Functions
    
    /// 書籍を取得します。
    func fetchBookList() {
        
        if case .loading = networkState { return }
        if totalPages < currentPage + 1 { return }
        
        networkState = .loading
        
        let receiveCompletionHandler: (Subscribers.Completion<APIError>) -> Void = { [weak self] completion in
            
            guard let self = self else { return }
            
            switch completion {
            case .failure(let error): self.networkState = .error(error)
            case .finished: self.networkState = .finished
            }
        }
        
        let receiveValueHandler: (request.Responses) -> Void = { [weak self] response in
            
            guard let self = self else { return }
            
            self.currentPage = response.currentPage
            self.bookListResponnse.append(contentsOf: response.result)
            self.totalPages = response.totalPages
        }
        
        do {
            let params = request.Parameters(page: (currentPage + 1).description, limit: limit.description)
            
            guard let token = try KeychainManager.keychain.get("token") else {
                throw NSError(domain: "", code: 0)
            }
            
            try APIClient()
                .makeDataTaskPublisher(from: request(headers: [header(headerField: "access_token", value: token)], params: params))
                .sink(receiveCompletion: receiveCompletionHandler, receiveValue: receiveValueHandler)
                .store(in: &binding)
        } catch APIError.urlEncode {
            networkState = .error(APIError.urlEncode)
        } catch APIError.jsonEncode {
            networkState = .error(APIError.jsonEncode)
        } catch let error {
            networkState = .error(error)
            assertionFailure("想定外のエラーです。")
            return
        }
    }
    
    /// データをリセットして書籍を取得しなおします。
    func resetData() {
        currentPage = 0
        totalPages = 1
        bookListResponnse = []
        networkState = .standby
        
        fetchBookList()
    }
}
