//
//  Keychain+Ethereum.swift
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

import Keychain

public extension Network {
    static var Ethereum: Network = Network(NETWORK_ETHEREUM())
}

extension KeyPath {
    static func ethereum(account: UInt32) throws -> KeyPath {
        return try KeychainResult<KeyPath>.wrap { path, error in
            keypath_ethereum_new(account, path, error)
        }.get()
    }
    
    static func ethereumMetamask(account: UInt32) throws -> KeyPath {
        return try KeychainResult<KeyPath>.wrap { path, error in
            keypath_ethereum_new_metamask(account, path, error)
        }.get()
    }
}
