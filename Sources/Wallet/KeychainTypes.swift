//
//  KeychainTypes.swift
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

import struct Keychain.ErrorPtr
import struct Keychain.Network
import var Keychain.WrongPassword
import var Keychain.NotEnoughData
import var Keychain.CantCalculateSeedSize
import var Keychain.DataError
import var Keychain.SeedIsNotSaved
import var Keychain.InvalidSeedSize
import var Keychain.KeyDoesNotExist
import var Keychain.KeyError
import var Keychain.KeyPathError
import var Keychain.MnemonicError
import var Keychain.KeyAlreadyExist

extension Network {
    init(_ network: Keychain.Network) {
        self.rawValue = network._0
    }
    
    var cNetwork: Keychain.Network {
        return Keychain.Network(_0: self.rawValue)
    }
}

public enum KeychainError: Swift.Error {
    case wrongPassword(String)
    case notEnoughData(String)
    case cantCalculateSeedSize(String)
    case dataError(String)
    case seedIsNotSaved(String)
    case invalidSeedSize(String)
    case keyDoesNotExist(String)
    case keyError(String)
    case keyPathError(String)
    case mnemonicError(String)
    case unknownError(String)
    case keyAlreadyExist(String)
    case networkIsNotSupported(Network)
    
    init(_ error: ErrorPtr) {
        let message = error.message.string
        switch error.error_type {
        case WrongPassword: self = .wrongPassword(message)
        case NotEnoughData: self = .notEnoughData(message)
        case CantCalculateSeedSize: self = .cantCalculateSeedSize(message)
        case DataError: self = .dataError(message)
        case SeedIsNotSaved: self = .seedIsNotSaved(message)
        case InvalidSeedSize: self = .invalidSeedSize(message)
        case KeyDoesNotExist: self = .keyDoesNotExist(message)
        case KeyError: self = .keyError(message)
        case KeyPathError: self = .keyPathError(message)
        case MnemonicError: self = .mnemonicError(message)
        case KeyAlreadyExist: self = .keyAlreadyExist(message)
        default: self = .unknownError(message)
        }
    }
}

typealias KeychainResult<T> = Result<T, KeychainError>

extension Swift.Result {
    static func wrap<S>(
        _ cb: @escaping (UnsafeMutablePointer<S>, UnsafeMutablePointer<ErrorPtr>) -> Bool
    ) -> KeychainResult<S> {
        var error = ErrorPtr()
        let val = UnsafeMutablePointer<S>.allocate(capacity: 1)
        defer { val.deallocate() }
        if !cb(val, &error) {
            defer { error.delete() }
            return .failure(error.error)
        }
        return .success(val.pointee)
    }
}
