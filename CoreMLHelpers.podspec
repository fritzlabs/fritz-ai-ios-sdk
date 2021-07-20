Pod::Spec.new do |s|
  s.name     = "CoreMLHelpers"
  s.version = '7.0.0'
  s.summary  = "Types and functions that make it a little easier to work with Core ML in Swift. "
  s.homepage = "https://github.com/hollance/CoreMLHelpers"
  s.author   = { "Matthijs Hollemans" => "matt@machinethink.net" }
  s.source   = { :git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.weak_framework = 'CoreML'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files = 'Source/CoreMLHelpers/**/*.{h,swift}'
end
