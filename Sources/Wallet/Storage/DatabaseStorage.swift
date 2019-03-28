//
//  DatabaseStorage.swift
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

extension Network: Value {
    public typealias Datatype = Int64
    
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Network {
        return Network(rawValue: UInt32(datatypeValue))
    }
    
    public var datatypeValue: Int64 {
        return Int64(self.rawValue)
    }
}

public class DatabaseWalletStorage {
    private let db: Connection
    private let queue: DispatchQueue
    
    public init(path: String) throws {
        db = try Connection(path)
        queue = DispatchQueue(label: "wallet database queue")
    }
    
    public func bootstrap() throws {
        try DatabaseWalletStorageMigrations(db: db).migrate()
    }
    
    private func getAddresses(accountId: String) throws -> [Network: [Address]] {
        let query = AddressDBModel.table.filter(AddressDBModel.accountId == accountId)
        var addresses = Dictionary<Network, Array<Address>>()
        for row in try db.prepare(query) {
            let address = try AddressDBModel(row: row).toAddress()
            var arr = addresses[address.network] ?? []
            arr.append(address)
            addresses[address.network] = arr
        }
        return addresses
    }
}

extension DatabaseWalletStorage: StorageProtocol {
    public func listWalletIds(offset: Int = 0, limit: Int = 1000, response: @escaping Response<[String]>) {
        queue.async {
            let query = WalletDBModel.table
                .select(WalletDBModel.id)
                .limit(limit, offset: offset)
            do {
                let data = try Array(self.db.prepare(query)).map{try $0.get(WalletDBModel.id)}
                response(.success(data))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func hasWallet(id: String, response: @escaping Response<Bool>) {
        queue.async {
            let query = WalletDBModel.table.filter(WalletDBModel.id == id).count
            do {
                response(try .success(self.db.scalar(query) == 1))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func loadWallet(id: String, response: @escaping Response<Wallet.StorageData>) {
        queue.async {
            let dbWallet: WalletDBModel
            do {
                if let row = try self.db.pluck(WalletDBModel.table.filter(WalletDBModel.id == id)) {
                    dbWallet = WalletDBModel(row: row)
                } else {
                    response(.failure(StorageError.noData(forKey: id)))
                    return
                }
            } catch let err {
                response(.failure(.internalError(err)))
                return
            }
            let dbAccounts: [AccountDBModel]
            do {
                let query = AccountDBModel.table.filter(AccountDBModel.walletId == id)
                dbAccounts = Array(try self.db.prepare(query)).map{AccountDBModel(row: $0)}
            } catch let err {
                response(.failure(.internalError(err)))
                return
            }
            var accounts: Array<Account.StorageData> = []
            do {
                for account in dbAccounts {
                    let addresses = try self.getAddresses(accountId: account.getId())
                    accounts.append(try account.toAccountStorage(addresses: addresses))
                }
                let wallet = try dbWallet.toWalletStorage(accounts: accounts)
                response(.success(wallet))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func saveWallet(wallet: Wallet.StorageData, response: @escaping Response<Void>) {
        queue.async {
            do {
                try self.db.run(
                    WalletDBModel.table.insert(
                        or: .replace,
                        WalletDBModel.setters(storage: wallet)
                    )
                )
                let walletId = wallet.id
                for account in wallet.accounts {
                    try self.db.run(
                        AccountDBModel.table.insert(
                            or: .replace,
                            AccountDBModel.setters(storage: account, walletId: walletId)
                        )
                    )
                    let accountId = account.id
                    for addresses in account.addresses.values {
                        for address in addresses {
                            try self.db.run(
                                AddressDBModel.table.insert(
                                    or: .replace,
                                    AddressDBModel.setters(
                                        storage: address, accountId: accountId
                                    )
                                )
                            )
                        }
                        
                    }
                }
            } catch let err {
                response(.failure(.internalError(err)))
                return
            }
            response(.success(()))
        }
    }
    
    public func removeWallet(id: String, response: @escaping Response<Void>) {
        queue.async {
            do {
                try self.db.run(WalletDBModel.table.filter(WalletDBModel.id == id).delete())
                response(.success(()))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func loadTransactions<T>(query: StorageQuery, response: @escaping Response<[T]>) where T : SerializableValueDecodable {
        fatalError("Not implemented")
    }
    
    public func saveTransactions<T>(transactions: Array<T>, response: @escaping Response<Void>) where T : SerializableValueEncodable {
        fatalError("Not implemented")
    }
    
    public func loadTokens<T>(query: StorageQuery, response: @escaping Response<[T]>) where T : SerializableValueDecodable {
        fatalError("Not implemented")
    }
    
    public func saveTokens<T>(transactions: Array<T>, response: @escaping Response<Void>) where T : SerializableValueEncodable {
        fatalError("Not implemented")
    }
}
