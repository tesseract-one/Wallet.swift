//
//  Manager+PromiseKit.swift
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
import PromiseKit

extension Manager {
    public func load(with id: String) -> Promise<Wallet> {
        return Promise { seal in
            self.load(with: id, response: seal.fromResult)
        }
    }

    public func save(wallet: Wallet) -> Promise<Void> {
        return Promise { seal in
            self.save(wallet: wallet, response: seal.fromResult)
        }
    }

    public func remove(walletId: String) -> Promise<Void> {
        return Promise { seal in
            self.remove(walletId: walletId, response: seal.fromResult)
        }
    }

    public func listWalletIds(offset: Int = 0, limit: Int = 10000) -> Promise<[String]> {
        return Promise { seal in
            self.listWalletIds(offset: offset, limit: limit, response: seal.fromResult)
        }
    }
}

extension Resolver {
    func fromResult<Err: Error>(_ swiftResult: Swift.Result<T, Err>) {
        switch swiftResult {
        case .success(let val): fulfill(val)
        case .failure(let err): reject(err)
        }
    }
}
