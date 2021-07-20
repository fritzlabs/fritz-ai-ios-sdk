Pod::Spec.new do |s|
  s.name = 'FritzVisionObjectModelFast'
  s.version = '7.0.0'
  s.summary = 'Official Fritz SDK for Swift 5.1 and Objective-C'
  s.homepage = 'https://www.fritz.ai'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE.md' }
  s.author = { 'Jameson Toole' => 'info@fritz.ai' }
  s.source = {:git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }

  s.requires_arc = true

  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'Accelerate', 'CoreImage', 'VideoToolbox'
  s.weak_frameworks = 'CoreML', 'Vision'

  s.dependency 'FritzVision'

  s.ios.deployment_target = '12.0'

  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'COREML_CODEGEN_LANGUAGE' => 'Swift', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files = 'Source/FritzVisionObjectModelFast/**/*.{h,swift,mlmodel}'
end
