# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FritzVisionRigidPose' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for FritzVisionRigidPose
  pod 'OpenCV', :inhibit_warnings => true

end

target 'AllFritzTests' do
  use_frameworks!
  pod 'Hippolyte'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
