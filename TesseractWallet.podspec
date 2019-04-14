Pod::Spec.new do |s|
  s.name             = 'TesseractWallet'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract Wallet SDK for Swift'

  s.description      = <<-DESC
Swift SDK for multi-network wallet implementation
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/swift-wallet-sdk'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/swift-wallet-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '10.0'

  s.module_name = 'Wallet'

  s.subspec 'Core' do |ss|
    ss.script_phase = {
      :name => 'Build Rust Binary',
      :script => 'bash "${PODS_TARGET_SRCROOT}/Keychain/build.sh"',
      :execution_position => :before_compile
    }

    ss.pod_target_xcconfig = {
      'SWIFT_INCLUDE_PATHS' => '"${PODS_TARGET_SRCROOT}"',
      'LIBRARY_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/Keychain"'
    }

    ss.preserve_paths = 'Keychain/**/*'

    ss.source_files = 'Sources/Wallet/**/*.swift'

    ss.dependency 'SerializableValue', '~> 0.0.1'
    ss.dependency 'SQLite.swift', '~> 0.11.0'
    ss.dependency 'SQLiteMigrationManager.swift', '~> 0.5.0'
  end

  s.subspec 'Ethereum' do |ss|
    ss.source_files = 'Sources/Ethereum/**/*.swift'

    ss.dependency 'TesseractWallet/Core'
    ss.dependency 'TesseractEthereumBase', '~> 0.0.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'TesseractWallet/Core'
    ss.dependency 'PromiseKit/CorePromise', '~> 6.8.0'
  end

  s.subspec 'EthereumPromiseKit' do |ss|
    ss.dependency 'TesseractWallet/Ethereum'
    ss.dependency 'TesseractWallet/PromiseKit'
    ss.dependency 'TesseractEthereumBase/PromiseKit', '~> 0.0.1'
  end

  s.default_subspecs = 'Core'
end
