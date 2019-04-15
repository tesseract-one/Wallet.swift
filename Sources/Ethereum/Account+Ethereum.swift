//
//  Account+Ethereum.swift
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
import BigInt
import EthereumBase

private let ETHEREUM_MAGIC_NUMBER: UInt8 = 27;

public extension Account {
    func eth_address() throws -> EthereumBase.Address {
        if let ethAddrs = addresses[.Ethereum] {
            return try EthereumBase.Address(rawAddress: ethAddrs[0].address)
        }
        throw KeychainError.networkIsNotSupported(.Ethereum)
    }
}

extension Account {
    func eth_signTx(
        isMetamask: Bool, tx: Transaction, chainId: UInt64,
        response: @escaping (Swift.Result<Data, SignProviderError>) -> Void
    ) {
        DispatchQueue.global().async {
            do {
                var keychain = try self.eth_keychain()
                let txData = try tx.rawData(chainId: BigUInt(chainId))
                var signature = try keychain.sign(
                    network: .Ethereum, data: txData, path: self.keyPath(isMetamask)
                )
                signature[signature.count-1] = signature[signature.count-1] + ETHEREUM_MAGIC_NUMBER
                response(.success(signature))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    func eth_signTypedData(
        isMetamask: Bool, data: TypedData,
        response: @escaping (Swift.Result<Data, SignProviderError>) -> Void
    ) {
        DispatchQueue.global().async {
            do {
                var keychain = try self.eth_keychain()
                var signature = try keychain.sign(
                    network: .Ethereum, data: data.signableMessageData(),
                    path: self.keyPath(isMetamask)
                )
                signature[signature.count-1] = signature[signature.count-1] + ETHEREUM_MAGIC_NUMBER
                response(.success(signature))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    func eth_signData(
        isMetamask: Bool, data: Data,
        response: @escaping (Swift.Result<Data, SignProviderError>) -> Void
    ) {
        DispatchQueue.global().async {
            var signData = "\u{19}Ethereum Signed Message:\n".data(using: .utf8)!
            signData.append(String(describing: data.count).data(using: .utf8)!)
            signData.append(data)
            do {
                var keychain = try self.eth_keychain()
                var signature = try keychain.sign(
                    network: .Ethereum, data: signData,
                    path: self.keyPath(isMetamask)
                )
                signature[signature.count-1] = signature[signature.count-1] + ETHEREUM_MAGIC_NUMBER
                response(.success(signature))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    func keyPath(_ isMetamask: Bool) throws -> KeyPath {
        return try isMetamask
            ? KeyPath.ethereumMetamask(account: self.index)
            : KeyPath.ethereum(account: self.index)
    }
    
    private func eth_keychain() throws -> KeychainPtr {
        if let support = networkSupport[.Ethereum] as? EthereumNetworkSupport {
            return support.keychain
        }
        throw KeychainError.networkIsNotSupported(.Ethereum)
    }
}
