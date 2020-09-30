//
//  APIClientProtocol.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Combine
import Foundation

protocol APIClientProtocol {
    func makeDataTaskPublisher<T: APIRequestProtocol>(from request: T) throws -> AnyPublisher<T.Responses, APIError>
}

extension APIClientProtocol {
    
    var decoder: JSONDecoder {
        let jsonDecorder = JSONDecoder()
        jsonDecorder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecorder
    }
}

enum APIError {
    case missingParameter
    case urlEncode
    case urlRequest
    case jsonEncode
    case jsonDecode
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        return NSLocalizedString("network_failure_message", comment: "")
    }
}

/// APIクライアント
public struct APIClient: APIClientProtocol {
    
    private let scheme = "http"
    private let host = "localhost:3000"
    
    /// 通信用のDataTaskPublisherを生成して返します。
    /// - Parameter requestType: リクエスト
    /// - Throws: エラー
    /// - Returns: DataTaskPublisher
    func makeDataTaskPublisher<T: APIRequestProtocol>(from requestType: T) throws -> AnyPublisher<T.Responses, APIError> {
        
        func makeUrlComponent() throws -> URLComponents {
            var urlComponent = URLComponents()
            urlComponent.scheme = scheme
            urlComponent.host = host
            urlComponent.path = requestType.path
            
            if requestType.method == "GET" {
                
                guard let queryItems = requestType.params?.makeQueryItems() else {
                    throw APIError.missingParameter
                }
                
                urlComponent.queryItems = queryItems
            }
            
            return urlComponent
        }
        
        func makeUrlRequest(url: URL) throws -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = requestType.method
            
            if requestType.method != "GET" {
                
                guard let httpBody = try? requestType.params.makeHttpBody() else {
                    throw APIError.jsonEncode
                }
                
                request.httpBody = httpBody
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            requestType.headers?.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.headerField)
            }
            
            return request
        }
                
        guard let url = try? makeUrlComponent().url else {
            assertionFailure("想定外のurlです。実装を見直してください。")
            throw APIError.urlEncode
        }
        
        guard let request = try? makeUrlRequest(url: url) else {
            assertionFailure("jsonのエンコードに失敗しました。")
            throw APIError.jsonEncode
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .mapError { _ in APIError.urlRequest }
            .decode(type: T.Responses.self, decoder: decoder)
            .mapError { _ in APIError.jsonDecode }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
