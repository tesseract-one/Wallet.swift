//
//  Keychain+Extension.swift
//  Wallet
//
//  Created by Yehor Popovych on 4/14/19.
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

extension KeychainManagerPtr {
    static let initializeLibrary: Void = {
        keychain_init_library()
    }()
    
    static func new() throws -> KeychainManagerPtr {
        return try KeychainResult<KeychainManagerPtr>.wrap { manager, error in
            keychain_manager_new(manager, error)
        }.get()
    }
    
    mutating func generateMnemonic() throws -> String {
        var sself = self
        var mnemonic = try KeychainResult<CharPtr>.wrap { mnemonic, error in
            keychain_manager_generate_mnemonic(&sself, English, mnemonic, error)
        }.get()
        defer { mnemonic?.delete() }
        return mnemonic!.string
    }
    
    mutating func keychain(
        mnemonic: String, password: String
    ) throws -> Data {
        var sself = self
        var data = try KeychainResult<DataPtr>.wrap { data, error in
            keychain_manager_keychain_data_from_mnemonic(&sself, mnemonic, password, English, data, error)
        }.get()
        defer { data.delete() }
        return data.data
    }
    
    mutating func keychain(data: Data, password: String) throws -> KeychainPtr {
        var sself = self
        let bytes = data.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: UInt8.self)
        }
        return try KeychainResult<KeychainPtr>.wrap { keychain, error in
            keychain_manager_keychain_from_data(
                &sself, bytes, UInt(data.count), password, keychain, error
            )
        }.get()
    }
    
    mutating func changePassword(data: Data, old: String, new: String) throws -> Data {
        var sself = self
        let bytes = data.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: UInt8.self)
        }
        var kData = try KeychainResult<DataPtr>.wrap { response, error in
            keychain_manager_change_password(
                &sself, bytes, UInt(data.count), old, new, response, error
            )
        }.get()
        defer { kData.delete() }
        return kData.data
    }
    
    mutating func delete() {
        delete_keychain_manager(&self)
    }
}

extension KeychainPtr {
    mutating func networks() throws -> [Network] {
        var sself = self
        var nets = try KeychainResult<NetworksPtr>.wrap { networks, error in
            keychain_networks(&sself, networks, error)
        }.get()
        defer { nets.delete() }
        return nets.networks.map { $0.network }
    }
    
    mutating func sign(network: Network, data: Data, path: KeyPath) throws -> Data {
        var sself = self
        let bytes = data.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: UInt8.self)
        }
        var signature = try KeychainResult<DataPtr>.wrap { response, error in
            keychain_sign(&sself, network.cNetwork, bytes, UInt(data.count), path, response, error)
        }.get()
        defer { signature.delete() }
        return signature.data
    }
    
    mutating func pubKey(network: Network, path: KeyPath) throws -> Data {
        var sself = self
        var keyData = try KeychainResult<DataPtr>.wrap { response, error in
            keychain_pub_key(&sself, network.cNetwork, path, response, error)
        }.get()
        defer { keyData.delete() }
        return keyData.data
    }
    
    mutating func delete() {
        delete_keychain(&self)
    }
}

extension NetworksPtr {
    var networks: UnsafeBufferPointer<Keychain.Network> {
        return UnsafeBufferPointer<Keychain.Network>(
            start: self.ptr, count: Int(self.count)
        )
    }
    
    mutating func delete() {
        delete_networks(&self)
    }
}

extension DataPtr {
    var data: Data {
        return Data(bytes: self.ptr, count: Int(self.len))
    }
    
    mutating func delete() {
        delete_data(&self)
    }
}

extension ErrorPtr {
    var error: KeychainError {
        return KeychainError(self)
    }
    
    mutating func delete() {
        delete_error(&self)
    }
}

extension CharPtr {
    var string: String {
        return String(utf8String: self)!
    }
    
    mutating func delete() {
        delete_string(self)
    }
}

extension Keychain.Network {
    var network: Network {
        return Network(self)
    }
}
