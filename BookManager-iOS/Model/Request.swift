//
//  RequestBody.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/05.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

typealias header = (headerField: String, value: String)

protocol APIRequestProtocol {
    associatedtype Responses: Decodable
    associatedtype Parameters: Encodable
    
    var path: String { get }
    var method: String { get }
    var headers: [header]? { get }
    var params: Parameters? { get set }
}

struct Request {
    struct Login: APIRequestProtocol {
        typealias Responses = Response.Login
        typealias Parameters = Params.Login
        
        let path = "/login"
        let method = "POST"
        let headers: [header]? = nil
        var params: Parameters?
    }

    struct SignUp: APIRequestProtocol {
        typealias Responses = Response.SignUp
        typealias Parameters = Params.SignUp

        let path = "/sign_up"
        let method = "POST"
        let headers: [header]? = nil
        var params: Parameters?
    }
    
    struct Logout: APIRequestProtocol {
        typealias Responses = Response.Logout
        typealias Parameters = Params.Logout
        
        let path = "/logout"
        let method = "DELETE"
        let headers: [header]?
        var params: Parameters?
    }
    
    struct BookList: APIRequestProtocol {
        typealias Responses = Response.BookList
        typealias Parameters = Params.BookList
        
        let path = "/books"
        let method = "GET"
        let headers: [header]?
        var params: Parameters?
    }
    
    struct BookEdit: APIRequestProtocol {
        typealias Responses = Response.BookEdit
        typealias Parameters = Params.BookEdit
        
        let id: Int
        var path: String {
            return "/books/" + id.description
        }
        let method = "PUT"
        
        let headers: [header]?
        var params: Parameters?
    }
    
    struct BookAdd: APIRequestProtocol {
        typealias Responses = Response.BookAdd
        typealias Parameters = Params.BookAdd
        
        let path = "/books"
        let method = "POST"
        let headers: [header]?
        var params: Parameters?
    }
}

struct Params {
    struct Login: Encodable {
        let email: String
        let password: String
    }
    
    struct SignUp: Encodable {
        let email: String
        let password: String
    }
    
    struct Logout: Encodable {}
    
    struct BookList: Encodable {
        // 書籍一覧のパラメータはQueryItemで付与するためStringにしています。
        let page: String
        let limit: String
    }
    
    struct BookEdit: Encodable {
        let name: String
        let image: String?
        let price: Int?
        let purchaseDate: String?
    }

    struct BookAdd: Encodable {
        let name: String
        let image: String?
        let price: Int?
        let purchaseDate: String?
    }
}

extension Encodable {
    
    /// 構造体からhttpBodyを作ります。
    /// - Throws: エンコードエラー
    /// - Returns: Json
    func makeHttpBody() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let httpBody = try? encoder.encode(self) else {
            assertionFailure()
            throw APIError.jsonEncode
        }
        return httpBody
    }
    
    /// 構造体からURLQueryItemを作ります。
    /// - Returns: URLQueryItemの配列
    func makeQueryItems() -> [URLQueryItem] {
        return Mirror(reflecting: self).children.compactMap { child -> URLQueryItem in
            return URLQueryItem(name: child.label ?? "",
                                value: child.value as? String ?? "")
        }
    }
}
