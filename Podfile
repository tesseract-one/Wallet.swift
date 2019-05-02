use_frameworks!
inhibit_all_warnings!

def common_pods
    pod 'Serializable.swift', '~> 0.1'

    pod 'Tesseract.EthereumTypes', '~> 0.1'
    
    pod 'SQLite.swift', '~> 0.12.0'
    pod 'SQLiteMigrationManager.swift', '~> 0.7.0'
    
    pod 'PromiseKit', '~> 6.8.0'
end

target 'Wallet-iOS' do
    platform :ios, '10.0'

    common_pods
end

target 'WalletTests-iOS' do
    platform :ios, '10.0'

    common_pods
end
