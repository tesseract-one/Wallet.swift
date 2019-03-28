Pod::Spec.new do |s|
  s.name             = 'TesseractWallet'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract Wallet SDK for Swift'

  s.description      = <<-DESC
Swift SDK for multi-network wallet implementation
                       DESC

  s.homepage         = 'https://github.com/tesseract.1/swift-wallet-sdk'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract.1/swift-wallet-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_io'

  s.ios.deployment_target = '10.0'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.module_name = 'Wallet'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Wallet/**/*.swift'

    ss.dependency 'TesseractKeychain', '~> 0.0.1'
    ss.dependency 'SerializableValue', '~> 0.0.1'
    ss.dependency 'SQLite.swift', '~> 0.11.0'
    ss.dependencw 'SQLiteMigrationManager.swift', '~> 0.5.0'
  end

  s.subspec 'Ethereum' do |ss|
    ss.source_files = 'Sources/Ethereum/**/*.swift'

    ss.dependency 'TesseractWallet/Core'
    ss.dependency 'TesseractEthereumBase', '~> 0.0.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'TesseractWallet/Core'
    ss.dependency 'PromiseKit', '~> 6.8.0'
  end

  s.default_subspecs = 'Core'
end
