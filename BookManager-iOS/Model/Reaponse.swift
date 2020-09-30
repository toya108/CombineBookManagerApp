//
//  Reaponse.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/23.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

struct Response {
    struct Login: Decodable {
        let status: Int
        let result: User
    }

    struct SignUp: Decodable {
        let status: Int
        let result: User
    }

    struct Logout: Decodable {
        let status: Int
    }

    struct BookList: Decodable {
        let status: Int
        let result: [Book]
        let totalCount: Int
        let totalPages: Int
        let currentPage: Int
        let limit: Int
    }

    struct BookEdit: Decodable {
        let status: Int
        let result: Book
    }

    struct BookAdd: Decodable {
        let status: Int
        let result: Book
    }

    // MARK: 共通レスポンス

    struct User: Decodable {
        let id: Int
        let email: String
        let token: String
    }

    struct Book: Decodable {
        let id: Int
        let name: String
        let image: String?
        let price: Int?
        let purchaseDate: String?
    }
}
