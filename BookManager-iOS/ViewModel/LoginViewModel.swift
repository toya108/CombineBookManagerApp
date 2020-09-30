//
//  LoginViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/04.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine
import KeychainAccess

/// ログイン画面用ViewModel
final class LoginViewModel: ViewModelProtocol {
    
    typealias request = Request.Login
    
    // MARK: Properties

    var mailAddress = ""
    var password = ""
    
    private var binding = Set<AnyCancellable>()

    @Published private(set) var networkState: NetWorkState = .standby
    
    // MARK: Internal Functions

    /// ログインバリデーションが有効化チェックします。
    /// - Returns: 全て有効ならtrueを返します。
    func validateUser() -> Bool {
        let validationResults = [EmailValidator().validate(mailAddress),
                                 PasswordValidator().validate(password)]
        return validationResults.allSatisfy { $0.isValid }
    }
    
    /// ログインバリデーションのエラーを返します。
    /// - Returns: エラー
    func extractLoginValidationErrors() -> [ValidationError] {
        let validationResults = [EmailValidator().validate(mailAddress),
                                 PasswordValidator().validate(password)]
        return validationResults.filter({ !$0.isValid }).compactMap { $0.error }
    }
    
    /// ログイン
    func login() {
        networkState = .loading
        
        let receiveCompletionHandler: (Subscribers.Completion<APIError>) -> Void = { [weak self] completion in
            
            guard let self = self else { return }
            
            switch completion {
            case .failure(let error): self.networkState = .error(error)
            case .finished: self.networkState = .finished
            }
        }
        
        let receiveValueHandler: (request.Responses) -> Void = {
            try? KeychainManager.keychain.set($0.result.token, key: "token")
        }
        
        do {
            let params = request.Parameters(email: mailAddress, password: password)
            try APIClient()
                .makeDataTaskPublisher(from: request(params: params))
                .sink(receiveCompletion: receiveCompletionHandler, receiveValue: receiveValueHandler)
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
