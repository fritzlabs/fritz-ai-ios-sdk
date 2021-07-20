Pod::Spec.new do |s|
  s.name = 'FritzVisionOutdoorSegmentationModelAccurate'
  s.version = '7.0.0'
  s.summary = 'Official Fritz SDK for Swift 5.1 and Objective-C'
  s.homepage = 'https://www.fritz.ai'
  s.license = { :type => 'Commercial', :file => 'LICENSE.md' }
  s.author = { 'Jameson Toole' => 'jameson@fritz.ai' }
  s.source = {:git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.1'
  s.frameworks = 'UIKit', 'CoreML', 'Foundation'

  s.dependency 'FritzVision'

  s.pod_target_xcconfig = { 'COREML_CODEGEN_LANGUAGE' => 'Swift', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files = 'Source/FritzVisionOutdoorSegmentationModelAccurate/**/*.{h,swift,mlmodel}'
end
