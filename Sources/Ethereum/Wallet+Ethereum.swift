//
//  Wallet+Ethereum.swift
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
import EthereumBase

public extension Wallet.AssociatedKeys {
    static let isMetamask = Wallet.AssociatedKeys(rawValue: "isMetamask")
}

extension Wallet: SignProvider {
    public func eth_accounts(networkId: UInt64, response: @escaping Response<[EthereumBase.Address]>) {
        DispatchQueue.global().async {
            do {
                try response(.success(self.accounts.map { try $0.eth_address() }))
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func eth_signTx(
        tx: Transaction, networkId: UInt64, chainId: UInt64,
        response: @escaping Response<Data>
    ) {
        DispatchQueue.global().async {
            do {
                let account = try self.eth_account(address: tx.from)
                account.eth_signTx(
                    isMetamask: self.isMetamask, tx: tx,
                    chainId: chainId, response: response
                )
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func eth_signData(
        account: EthereumBase.Address, data: Data, networkId: UInt64,
        response: @escaping Response<Data>
    ) {
        DispatchQueue.global().async {
            do {
                let account = try self.eth_account(address: account)
                account.eth_signData(
                    isMetamask: self.isMetamask, data: data, response: response
                )
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    public func eth_signTypedData(
        account: EthereumBase.Address, data: TypedData, networkId: UInt64,
        response: @escaping Response<Data>
    ) {
        DispatchQueue.global().async {
            do {
                let account = try self.eth_account(address: account)
                account.eth_signTypedData(
                    isMetamask: self.isMetamask, data: data, response: response
                )
            } catch let err {
                response(.failure(.internalError(err)))
            }
        }
    }
    
    private func eth_account(address: EthereumBase.Address) throws -> Account {
        let opAccount = try accounts.first { try $0.eth_address() == address }
        guard let account = opAccount else {
            throw SignProviderError.accountDoesNotExist(address)
        }
        return account
    }
    
    private var isMetamask: Bool {
        return associatedData[.isMetamask]?.bool ?? false
    }
}
