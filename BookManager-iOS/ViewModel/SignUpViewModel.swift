//
//  SignUpViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/04.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine

/// アカウント設定画面用ViewModel
final class SignUpViewModel: ViewModelProtocol {
    
    typealias request = Request.SignUp
    
    // MARK: Properties
    
    var mailAddress = ""
    var password = ""
    var confirmPassword = ""
    
    private var binding = Set<AnyCancellable>()
    @Published private(set) var networkState: NetWorkState = .standby
    
    // MARK: Internal Functions
    
    /// サインアップバリデーションが有効化チェックします。
    /// - Returns: 全て有効ならtrueを返します。
    func validateUser() -> Bool {
        let validationResults = [EmailValidator().validate(mailAddress),
                                 PasswordValidator().validate(password),
                                 ConfirmPasswordValidator(password: password).validate(confirmPassword)]
        return validationResults.allSatisfy { $0.isValid }
    }
    
    /// サインアップバリデーションのエラーを返します。
    /// - Returns: エラー
    func extractSingUpValidationErrors() -> [ValidationError] {
        let validationResults = [EmailValidator().validate(mailAddress),
                                 PasswordValidator().validate(password),
                                 ConfirmPasswordValidator(password: password).validate(confirmPassword)]
        return validationResults.filter({ !$0.isValid }).compactMap { $0.error }
    }
    
    /// サインアップ
    func signUp() {
        
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
            try APIClient().makeDataTaskPublisher(from: request(params: params))
                .sink(receiveCompletion: receiveCompletionHandler, receiveValue: receiveValueHandler)
                .store(in: &binding)
        } catch APIError.urlEncode {
            networkState = .error(APIError.urlEncode)
        } catch APIError.jsonEncode {
            networkState = .error(APIError.jsonEncode)
        } catch {
            fatalError("想定外のエラーです。")
        }
    }
}
