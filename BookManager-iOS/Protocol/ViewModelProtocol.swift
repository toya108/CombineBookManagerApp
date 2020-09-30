//
//  ViewModelProtocol.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/23.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype request: APIRequestProtocol
}

enum NetWorkState {
    case standby
    case loading
    case finished
    case error(Error)
}
