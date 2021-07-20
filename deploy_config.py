FRITZ_REPO_BASE = "git@github.com:fritzlabs"


def _generate_blocks(framework_base, variants):
    return [
        {
            "podspec": f"{framework_base}{variant}.podspec",
            "pod_repo": "master",
            "bundled_frameworks": [
                f"Frameworks/{framework_base}{variant}.framework",
            ],
            "synchronize": True,
        }
        for variant in variants
    ]


REPOS = {
    "fritz-ai-ios-sdk": {
        "repo_url": f"{FRITZ_REPO_BASE}/fritz-ai-ios-sdk.git",
        "framework_folder": "../fritz-ai-ios-sdk",
        "podspecs": [
            {
                "podspec": "FritzBase.podspec",
                "pod_repo": "master",
                "bundled_frameworks": [
                    "Frameworks/FritzCore.framework",
                    "Frameworks/Fritz.framework",
                    "Frameworks/FritzVision.framework",
                    "Frameworks/FritzManagedModel.framework",
                    "Frameworks/CoreMLHelpers.framework",
                ],
                "update_repo_after": True,
                "synchronize": False,
            }
        ],
    },
}

MODEL_FRAMEWORKS = {
    "FritzVisionLabelModel": ["Fast"],
    "FritzVisionObjectModel": ["Fast"],
    "FritzVisionStyleModelPatterns": [""],
    "FritzVisionStyleModelPaintings": [""],
    "FritzVisionMultiPoseModel": [""],
    "FritzVisionRigidPose": [""],
    "FritzVisionPeopleAndPetSegmentationModel": ["Accurate"],
    "FritzVisionPeopleSegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionLivingRoomSegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionOutdoorSegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionSkySegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionPetSegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionHairSegmentationModel": ["Fast", "Accurate", "Small"],
    "FritzVisionHumanPoseModel": ["Fast", "Accurate", "Small"],
}

# Hacky way of generating all blocks.
for framework, variants in MODEL_FRAMEWORKS.items():
    REPOS["fritz-ai-ios-sdk"]["podspecs"].extend(_generate_blocks(framework, variants))

REPOS["fritz-ai-ios-sdk"]["podspecs"].append(
    {
        "podspec": "Fritz.podspec",
        "pod_repo": "master",
        "bundled_frameworks": [],
        "update_repo_before": True,
        "synchronize": True,
    }
)
