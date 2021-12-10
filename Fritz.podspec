Pod::Spec.new do |s|
  s.name = 'Fritz'
  s.version = '7.0.1'
  s.summary = 'Official Fritz SDK for Swift 5.0 and Objective-C'
  s.homepage = 'https://fritz.ai'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE.md' }
  s.author = { 'Jameson Toole' => 'info@fritz.ai' }
  s.source = { :git => 'https://github.com/fritzlabs/fritz-ai-ios-sdk.git', :tag => s.version.to_s }

  s.requires_arc = true

  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'Accelerate', 'CoreImage', 'VideoToolbox'
  s.weak_frameworks = 'CoreML', 'Vision'

  s.ios.deployment_target = '12.0'

  s.swift_version = '5.3'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.default_subspec = 'Vision'

  s.source_files = 'Source/Fritz/**/*.{h,swift}'

  s.subspec 'Vision' do |vision|
    vision.dependency 'FritzVision', '7.0.1'
  end

  s.subspec 'VisionLabelModel' do |vision|
    vision.subspec 'Fast' do |sub|
      sub.dependency 'FritzVisionLabelModelFast', '7.0.1'
    end
  end

  s.subspec 'VisionObjectModel' do |vision|
    vision.subspec 'Fast' do |sub|
      sub.dependency 'FritzVisionObjectModelFast', '7.0.1'
    end
  end

  s.subspec 'VisionPoseModel' do |vision|
    vision.subspec 'Human' do |pose|
      pose.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionHumanPoseModelAccurate', '7.0.1'
      end
      pose.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionHumanPoseModelFast', '7.0.1'
      end
      pose.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionHumanPoseModelSmall', '7.0.1'
      end
    end
  end

  s.subspec 'VisionRigidPose' do |vision|
    vision.dependency 'FritzVisionRigidPose', '7.0.1'
  end

  s.subspec 'VisionMultiPoseModel' do |vision|
    vision.dependency 'FritzVisionMultiPoseModel', '7.0.1'
  end

  s.subspec 'VisionStyleModel' do |style|
    style.subspec 'Paintings' do |paintings|
      paintings.dependency 'FritzVisionStyleModelPaintings', '7.0.1'
    end
    style.subspec 'Patterns' do |patterns|
      patterns.dependency 'FritzVisionStyleModelPatterns', '7.0.1'
    end
  end

  s.subspec 'VisionSegmentationModel' do |vision|
    vision.subspec 'People' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionPeopleSegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionPeopleSegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionPeopleSegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'LivingRoom' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionLivingRoomSegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionLivingRoomSegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionLivingRoomSegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'Outdoor' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionOutdoorSegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionOutdoorSegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionOutdoorSegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'Hair' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionHairSegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionHairSegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionHairSegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'Sky' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionSkySegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionSkySegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionSkySegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'Pet' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionPetSegmentationModelAccurate', '7.0.1'
      end
      seg.subspec 'Fast' do |sub|
        sub.dependency 'FritzVisionPetSegmentationModelFast', '7.0.1'
      end
      seg.subspec 'Small' do |sub|
        sub.dependency 'FritzVisionPetSegmentationModelSmall', '7.0.1'
      end
    end

    vision.subspec 'PeopleAndPet' do |seg|
      seg.subspec 'Accurate' do |sub|
        sub.dependency 'FritzVisionPeopleAndPetSegmentationModelAccurate', '7.0.1'
      end
    end
  end
end
