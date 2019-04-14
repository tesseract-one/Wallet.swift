//
//  NetworkSupport+Ethereum.swift
//  Wallet
//
//  Created by Yehor Popovych on 3/28/19.
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
import CryptoSwift

public struct EthereumNetwork: NetworkSupportFactory {
    public let network: Network
    
    public init() {
        network = .Ethereum
    }
    
    public func withKeychain(keychain: KeychainPtr, for wallet: Wallet) -> NetworkSupport {
        return EthereumNetworkSupport(
            keychain: keychain,
            isMetamask: wallet.associatedData[.isMetamask]?.bool ?? false
        )
    }
}

protocol EthereumKeychainNetworkSuppport: NetworkSupport {
    var keychain: KeychainPtr { get }
}

struct EthereumNetworkSupport: EthereumKeychainNetworkSuppport {
    let keychain: KeychainPtr
    let isMetamask: Bool
    
    init(keychain: KeychainPtr, isMetamask: Bool) {
        self.keychain = keychain
        self.isMetamask = isMetamask
    }
    
    func createFirstAddress(accountIndex: UInt32) throws -> Address {
        let keyPath: KeyPath = try self.isMetamask
            ? KeyPath.ethereumMetamask(account: accountIndex)
            : KeyPath.ethereum(account: accountIndex)
        var keychain = self.keychain
        var pubKey = try keychain.pubKey(network: .Ethereum, path: keyPath).bytes
        pubKey.remove(at: 0)
        var hash = SHA3(variant: .keccak256).calculate(for: pubKey)
        guard hash.count == 32 else {
            throw KeychainError.keyError("Hash from pubkey length != 32")
        }
        return Address(index: 0, address: Data(hash[12...]), network: .Ethereum)
    }
}

