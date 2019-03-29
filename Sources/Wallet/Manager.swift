//
//  Manager.swift
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
import Keychain

public struct NewWalletData {
    public let encrypted: Data
    public let mnemonic: String
    
    internal init(mnemonic: String, encrypted: Data) {
        self.mnemonic = mnemonic
        self.encrypted = encrypted
    }
}

public class Manager {
    
    public enum Error: Swift.Error {
        case storageError(StorageError)
        case serializationError(Swift.Error)
    }
    
    public private(set) var networks: Dictionary<Network, NetworkSupportFactory>
    public let storage: StorageProtocol
    
    public init(networks: [NetworkSupportFactory], storage: StorageProtocol) {
        let tuple = networks.map { ($0.network, $0) }
        self.networks = Dictionary(uniqueKeysWithValues: tuple)
        self.storage = storage
    }
    
    public func newWalletData(password: String) throws -> NewWalletData {
        let mnemonic = try Keychain.generateMnemonic()
        return try restoreWalletData(mnemonic: mnemonic, password: password)
    }
    
    public func restoreWalletData(mnemonic: String, password: String) throws -> NewWalletData {
        let data = try Keychain.fromMnemonic(mnemonic: mnemonic, password: password)
        return NewWalletData(mnemonic: mnemonic, encrypted: data.encrypted)
    }
    
    public func create(from data: NewWalletData, password: String) throws -> Wallet {
        let id = UUID().uuidString
        let wallet = Wallet(id: id, privateData: data.encrypted, networks: networks)
        try wallet.unlock(password: password)
        _ = try wallet.addAccount()
        return wallet
    }
    
    public func has(wallet id: String,  response: @escaping (Swift.Result<Bool, Error>) -> Void) {
        storage.hasWallet(id: id) { result in
            response(result.mapError { .storageError($0) })
        }
    }
    
    public func load(with id: String, response: @escaping (Swift.Result<Wallet, Error>) -> Void) {
        storage.loadWallet(id: id) { result in
            response(
                result
                .mapError{ .storageError($0) }
                .flatMap { data in
                    do {
                        return try .success(Wallet(data: data, networks: self.networks))
                    } catch let err {
                        return .failure(.serializationError(err))
                    }
                }
            )
        }
    }
    
    public func save(wallet: Wallet, response: @escaping (Swift.Result<Void, Error>) -> Void) {
        storage.saveWallet(wallet: wallet.storageData) { result in
            response(result.mapError { .storageError($0) })
        }
    }
    
    public func remove(walletId: String, response: @escaping (Swift.Result<Void, Error>) -> Void) {
        storage.removeWallet(id: walletId) { result in
            response(result.mapError { .storageError($0) })
        }
    }
    
    public func listWalletIds(
        offset: Int = 0, limit: Int = 10000,
        response: @escaping (Swift.Result<[String], Error>) -> Void
    ) {
        storage.listWalletIds(offset: offset, limit: limit) { result in
            response(result.mapError { .storageError($0) })
        }
    }
}

