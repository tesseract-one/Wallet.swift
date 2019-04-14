//
//  Account.swift
//  Wallet
//
//  Created by Yehor Popovych on 3/6/19.
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

public class Account {
    public let id: String
    public let index: UInt32
    public private(set) var addresses: Dictionary<Network, Array<Address>>
    public var associatedData: Dictionary<AssociatedKeys, SerializableProtocol>
    
    public private(set) var networkSupport: Dictionary<Network, NetworkSupport> = [:]
    
    init(
        id: String, index: UInt32,
        addresses: Dictionary<Network, Array<Address>>,
        associatedData: Dictionary<AssociatedKeys, SerializableProtocol>
    ) {
        self.id = id
        self.index = index
        self.addresses = addresses
        self.associatedData = associatedData
    }
    
    init(id: String, index: UInt32, networkSupport: Dictionary<Network, NetworkSupport>? = nil) throws {
        self.id = id
        self.index = index
        self.addresses = [:]
        self.associatedData = [:]
        
        if let supported = networkSupport {
            try setNetworkSupport(supported: supported)
        }
    }
    
    func setNetworkSupport(supported: Dictionary<Network, NetworkSupport>) throws {
        networkSupport = supported
        
        for support in networkSupport {
            if addresses[support.key] == nil || addresses[support.key]!.count == 0 {
                addresses[support.key] = [try support.value.createFirstAddress(accountIndex: index)]
            }
        }
        
        let removed = Set(addresses.keys).subtracting(networkSupport.keys)
        for net in removed {
            addresses.removeValue(forKey: net)
        }
    }
}

extension Account {
    public struct AssociatedKeys: RawRepresentable, Codable, Hashable, Equatable {
        public typealias RawValue = String
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    public struct StorageData: Codable, Equatable {
        public let id: String
        public let index: UInt32
        public let addresses: Dictionary<Network, Array<Address>>
        public let associatedData: Dictionary<String, SerializableValue>
        
        public init(
            id: String,
            index: UInt32,
            addresses: Dictionary<Network, Array<Address>>,
            associatedData: Dictionary<String, SerializableValue>
        ) {
            self.id = id
            self.index = index
            self.addresses = addresses
            self.associatedData = associatedData
        }
    }
    
    convenience init(storageData: StorageData) throws {
        var associatedData = Dictionary<AssociatedKeys, SerializableProtocol>()
        for (key, val) in storageData.associatedData {
            associatedData[AssociatedKeys(rawValue: key)] = val
        }
        self.init(
            id: storageData.id, index: storageData.index,
            addresses: storageData.addresses, associatedData: associatedData
        )
    }
    
    var storageData: StorageData {
        var data = Dictionary<String, SerializableValue>()
        for (key, val) in associatedData {
            data[key.rawValue] = val.serializable
        }
        return StorageData(
            id: id, index: index,
            addresses: addresses, associatedData: data
        )
    }
}

extension Account: Equatable {
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.storageData == rhs.storageData
    }
}
