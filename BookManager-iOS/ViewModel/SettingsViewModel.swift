//
//  SettingsViewModel.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/24.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import Combine

/// ログイン画面用ViewModel
final class SettingsViewModel: ViewModelProtocol {
    
    typealias request = Request.Logout
    
    private var binding = Set<AnyCancellable>()

    @Published private(set) var networkState: NetWorkState = .standby
    
    /// ログイン
    func logout() {
        networkState = .loading
        
        let receiveCompletionHandler: (Subscribers.Completion<APIError>) -> Void = { [weak self] completion in
            
            guard let self = self else { return }
            
            switch completion {
            case .failure(let error): self.networkState = .error(error)
            case .finished: self.networkState = .finished
            }
        }
        
        let receiveValueHandler: (request.Responses) -> Void = {_ in
            try? KeychainManager.keychain.remove("token")
        }
        
        do {
            guard let token = try KeychainManager.keychain.get("token") else {
                throw NSError(domain: "", code: 0)
            }
            
            try APIClient()
                .makeDataTaskPublisher(from: request(headers: [header(headerField: "access_token", value: token)]))
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
