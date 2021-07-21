Pod::Spec.new do |s|
    s.name = 'FritzBase'
    s.version = '7.0.0'
    s.summary = 'Official Fritz SDK for Swift 5.1 and Objective-C'
    s.homepage = 'https://www.fritz.ai'
    s.license = { :type => 'Apache 2.0', :file => 'LICENSE.md' }
    s.author = { 'Jameson Toole' => 'info@fritz.ai' }
    s.source = {:git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }

    s.requires_arc = true

    s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'Accelerate', 'CoreImage', 'VideoToolbox'
    s.weak_frameworks = 'CoreML', 'Vision'

    s.ios.deployment_target = '14.5'

    s.swift_version = '5.1'

    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

    s.default_subspec = 'FritzManagedModel'

    s.subspec 'Core' do |core|
      core.dependency "FritzCore", '7.0.0'
    end

    s.subspec 'ManagedModel' do |analytics|
      analytics.dependency "FritzManagedModel", '7.0.0'
    end

    s.subspec 'CoreMLHelpers' do |helpers|
      helpers.dependency "FritzCoreMLHelpers", '7.0.0'
    end

    s.subspec 'FritzVision' do |helpers|
      helpers.dependency 'FritzVision', '7.0.0'
    end
  end