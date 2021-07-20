Pod::Spec.new do |s|
    s.name = 'FritzBase'
    s.version = '7.0.0'
    s.summary = 'Official Fritz SDK for Swift 5.1 and Objective-C'
    s.homepage = 'https://www.fritz.ai'
    s.license = { :type => 'Apache 2.0', :file => 'LICENSE.md' }
    s.author = { 'Chris Kelly' => 'engineering@fritz.ai' }
    s.source = {:git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }

    s.requires_arc = true

    s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'Accelerate', 'CoreImage', 'VideoToolbox'
    s.weak_frameworks = 'CoreML', 'Vision'

    s.ios.deployment_target = '10.0'

    s.swift_version = '5.1'

    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

    s.default_subspec = 'ManagedModel'

    s.subspec 'Core' do |core|
      core.source_files = 'Source/FritzCore'
    end

    s.subspec 'ManagedModel' do |analytics|
      analytics.dependency 'FritzBase/Core', '7.0.0'
      analytics.source_files = "Source/FritzManagedModel"
    end

    s.subspec 'CoreMLHelpers' do |helpers|
      helpers.source_files = "Source/CoreMLHelpers"
    end

    s.subspec 'Vision' do |helpers|
      helpers.dependency 'FritzBase/Core', '7.0.0'
      helpers.dependency 'FritzBase/CoreMLHelpers', '7.0.0'
      helpers.dependency 'FritzBase/ManagedModel', '7.0.0'
      helpers.source_files = 'Source/FritzVision'
    end
  end