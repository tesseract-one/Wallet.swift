//
//  DatabaseStorageMigrations.swift
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
import Keychain
import SQLite
import SQLiteMigrationManager

private struct InitialMigration: Migration {
    let version: Int64 = 2019_03_25_15_43_00
    
    private let walletTable = Table("Wallet")
    private let accountTable = Table("Account")
    
    private func createWallet(db: Connection) throws {
        try db.run(walletTable.create { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(Expression<Blob>("keys"))
            t.column(Expression<String>("data"))
        })
    }
    
    private func createAccount(db: Connection) throws {
        let index = Expression<Int64>("index")
        try db.run(accountTable.create { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(index)
            t.column(Expression<String>("data"))
            t.column(Expression<String>("walletId"))
            
            t.foreignKey(Expression<String>("walletId"), references: walletTable, Expression<String>("id"), delete: .cascade)
        })
        try db.run(accountTable.createIndex(index))
    }
    
    private func createAddress(db: Connection) throws {
        let index = Expression<Int64>("index")
        let network = Expression<Network>("network")
        let accountId = Expression<String>("accountId")
        let table = Table("Address")
        try db.run(table.create { t in
            t.column(index)
            t.column(network)
            t.column(Expression<Blob>("address"))
            t.column(accountId)
            
            t.primaryKey(index, network, accountId)
            
            t.foreignKey(accountId, references: accountTable, Expression<String>("id"), delete: .cascade)
        })
        try db.run(table.createIndex(network))
    }
    
    func migrateDatabase(_ db: Connection) throws {
        try createWallet(db: db)
        try createAccount(db: db)
        try createAddress(db: db)
    }
}

struct DatabaseWalletStorageMigrations {
    static let migrations: [Migration] = [
        InitialMigration()
    ]
    private let manager: SQLiteMigrationManager
    
    init(db: Connection) {
        manager = SQLiteMigrationManager(
            db: db,
            migrations: DatabaseWalletStorageMigrations.migrations,
            bundle: nil
        )
    }
    
    func migrate() throws {
        if !manager.hasMigrationsTable() {
            try manager.createMigrationsTable()
        }
        if manager.needsMigration() {
            try manager.migrateDatabase()
        }
    }
}
