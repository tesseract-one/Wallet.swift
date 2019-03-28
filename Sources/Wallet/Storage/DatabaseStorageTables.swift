//
//  DatabaseStorageTables.swift
//  Wallet
//
//  Created by Yehor Popovych on 3/25/19.
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
import SQLite

private let encoder: JSONEncoder = {
    let enc = JSONEncoder()
    enc.dataEncodingStrategy = .base64
    enc.dateEncodingStrategy = .iso8601
    return enc
}()

private let decoder: JSONDecoder = {
    let dec = JSONDecoder()
    dec.dataDecodingStrategy = .base64
    dec.dateDecodingStrategy = .iso8601
    return dec
}()

struct WalletDBModel {
    static let table = Table("Wallet")
    // fields
    static let id = Expression<String>("id")
    static let keys = Expression<Blob>("keys")
    static let data = Expression<String>("data")
    
    private let row: Row
    
    init(row: Row) {
        self.row = row
    }
    
    func getId() throws -> String {
        return try row.get(WalletDBModel.id)
    }
    
    func getKeys() throws -> Data {
        return try Data(row.get(WalletDBModel.keys).bytes)
    }
    
    func getAssociatedData() throws -> Dictionary<String, SerializableValue> {
        let data = try row.get(AccountDBModel.data).data(using: .utf8)!
        return try decoder.decode(Dictionary<String, SerializableValue>.self, from: data)
    }
    
    func toWalletStorage(accounts: [Account.StorageData]) throws -> Wallet.StorageData {
        return try Wallet.StorageData(
            id: getId(),
            privateKeys: getKeys(),
            accounts: accounts,
            associatedData: getAssociatedData()
        )
    }
    
    static func setters(storage: Wallet.StorageData) throws -> [Setter] {
        let data = try encoder.encode(storage.associatedData)
        return [
            WalletDBModel.id <- storage.id,
            WalletDBModel.keys <- Blob(bytes: storage.privateKeys.bytes),
            WalletDBModel.data <- String(data: data, encoding: .utf8)!
        ]
    }
}

struct AccountDBModel {
    static let table = Table("Account")
    // fields
    static let id = Expression<String>("id")
    static let index = Expression<Int64>("index")
    static let data = Expression<String>("data")
    // references
    static let walletId = Expression<String>("walletId")
    
    private let row: Row
    
    init(row: Row) {
        self.row = row
    }
    
    func getId() throws -> String {
        return try row.get(AccountDBModel.id)
    }
    
    func getIndex() throws -> Int64 {
        return try row.get(AccountDBModel.index)
    }
    
    func getAssociatedData() throws -> Dictionary<String, SerializableValue> {
        let data = try row.get(AccountDBModel.data).data(using: .utf8)!
        return try decoder.decode(Dictionary<String, SerializableValue>.self, from: data)
    }
    
    func toAccountStorage(addresses: [Network: [Address]]) throws -> Account.StorageData {
        return try Account.StorageData(
            id: getId(),
            index: UInt32(getIndex()),
            addresses: addresses,
            associatedData: getAssociatedData()
        )
    }
    
    static func setters(storage: Account.StorageData, walletId: String) throws -> [Setter] {
        let data = try encoder.encode(storage.associatedData)
        return [
            AccountDBModel.id <- storage.id,
            AccountDBModel.index <- Int64(storage.index),
            AccountDBModel.data <- String(data: data, encoding: .utf8)!,
            AccountDBModel.walletId <- walletId
        ]
    }
}

struct AddressDBModel {
    static let table = Table("Address")
    // fields
    static let index = Expression<Int64>("index")
    static let network = Expression<Network>("network")
    static let address = Expression<Blob>("address")
    // references
    static let accountId = Expression<String>("accountId")
    
    private let row: Row
    
    init(row: Row) {
        self.row = row
    }
    
    func getIndex() throws -> Int64 {
        return try row.get(AddressDBModel.index)
    }
    
    func getNetwork() throws -> Network {
        return try row.get(AddressDBModel.network)
    }
    
    func getAddress() throws -> Blob {
        return try row.get(AddressDBModel.address)
    }
    
    func toAddress() throws -> Address {
        return try Address(
            index: UInt32(getIndex()),
            address: Data(getAddress().bytes),
            network: getNetwork()
        )
    }
    
    static func setters(storage: Address, accountId: String) throws -> [Setter] {
        return [
            AddressDBModel.index <- Int64(storage.index),
            AddressDBModel.network <- storage.network,
            AddressDBModel.address <- Blob(bytes: storage.address.bytes),
            AddressDBModel.accountId <- accountId
        ]
    }
}
