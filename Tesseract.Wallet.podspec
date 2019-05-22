Pod::Spec.new do |s|
  s.name             = 'Tesseract.Wallet'
  s.version          = '0.1.4'
  s.summary          = 'Tesseract Wallet SDK for Swift'

  s.description      = <<-DESC
Tesseract DApps Platform multi-network Wallet implementation for Swift
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/Wallet.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/Wallet.swift.git', :tag => s.version.to_s, :submodules => true }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '10.0'

  s.module_name = 'Wallet'

  s.swift_versions = ['5.0']

  s.subspec 'Core' do |ss|
    ss.script_phase = {
      :name => 'Build Rust Binary',
      :script => 'bash "${PODS_TARGET_SRCROOT}/Keychain/build.sh"',
      :execution_position => :before_compile
    }

    ss.pod_target_xcconfig = {
      'SWIFT_INCLUDE_PATHS' => '"${PODS_TARGET_SRCROOT}"',
      'LIBRARY_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/Keychain"',
      'ENABLE_BITCODE' => 'NO'
    }

    ss.preserve_paths = 'Keychain/**/*'

    ss.source_files = 'Sources/Wallet/**/*.swift'

    ss.dependency 'Serializable.swift', '~> 0.1'
    ss.dependency 'SQLite.swift', '~> 0.12.0'
    ss.dependency 'SQLiteMigrationManager.swift', '~> 0.7.0'
  end

  s.subspec 'Ethereum' do |ss|
    ss.source_files = 'Sources/Ethereum/**/*.swift'

    ss.dependency 'Tesseract.Wallet/Core'
    ss.dependency 'Tesseract.EthereumTypes', '~> 0.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'Tesseract.Wallet/Core'
    ss.dependency 'PromiseKit/CorePromise', '~> 6.8.0'
  end

  s.default_subspecs = 'Core'
end
