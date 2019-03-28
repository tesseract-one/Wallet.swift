//
//  Storage.swift
//  Wallet
//
//  Created by Yehor Popovych on 3/21/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Serializable

public enum StorageError: Error {
    case noData(forKey: String)
    case wrongData(forKey: String)
    case internalError(Error)
}

public struct StorageQuery {
    public let offset: UInt32? = nil
    public let limit: UInt32? = nil
    public let sortBy: String? = nil
    public let ascending: Bool = true
    
    public var rules: Dictionary<String, SerializableValue> = [:]
}

public protocol StorageProtocol {
    typealias Response<Type> = (Result<Type, StorageError>) -> Void
    
    func listWalletIds(offset: Int, limit: Int, response: @escaping Response<[String]>)
    func hasWallet(id: String, response: @escaping Response<Bool>)
    func loadWallet(id: String, response: @escaping Response<Wallet.StorageData>)
    func saveWallet(wallet: Wallet.StorageData, response: @escaping Response<Void>)
    func removeWallet(id: String, response: @escaping Response<Void>)
    
    func loadTransactions<T: SerializableValueDecodable>(
        query: StorageQuery,
        response: @escaping Response<[T]>
    )
    func saveTransactions<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping Response<Void>
    )
    
    func loadTokens<T: SerializableValueDecodable>(
        query: StorageQuery,
        response: @escaping Response<[T]>
    )
    func saveTokens<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping Response<Void>
    )
}
