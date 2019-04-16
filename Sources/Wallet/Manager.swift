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
        case initializationError(String)
    }
    
    private var manager: KeychainManagerPtr
    
    public private(set) var networks: Dictionary<Network, NetworkSupportFactory>
    public let storage: StorageProtocol
    
    public init(networks: [NetworkSupportFactory], storage: StorageProtocol) throws {
        // Library initialization
        let _ = KeychainManagerPtr.initializeLibrary
        
        self.manager = try KeychainManagerPtr.new()
        
        let tuple = networks.map { ($0.network, $0) }
        self.networks = Dictionary(uniqueKeysWithValues: tuple)
        self.storage = storage
    }
    
    deinit {
        manager.delete()
    }
    
    public func newWalletData(password: String) throws -> NewWalletData {
        return try restoreWalletData(mnemonic: manager.generateMnemonic(), password: password)
    }
    
    public func restoreWalletData(mnemonic: String, password: String) throws -> NewWalletData {
        var (keychain, encrypted) = try manager.keychain(mnemonic: mnemonic, password: password)
        defer { keychain.delete() }
        return NewWalletData(mnemonic: mnemonic, encrypted: encrypted)
    }
    
    public func create(from data: NewWalletData) throws -> Wallet {
        let id = UUID().uuidString
        let wallet = Wallet(id: id, privateData: data.encrypted, manager: self)
        return wallet
    }
    
    func keychain(data: Data, password: String) throws -> KeychainPtr {
        return try manager.keychain(data: data, password: password)
    }
    
    func changePassword(data: Data, oldPwd: String, newPwd: String) throws -> Data {
        return try manager.changePassword(data: data, old: oldPwd, new: newPwd)
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
                        return try .success(Wallet(data: data, manager: self))
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

