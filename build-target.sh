#!/bin/bash

# Script origins were https://github.com/couchbase/couchbase-lite-ios/blob/master/Scripts/build_framework.sh
# but has heavily diverged since.
set -e

function usage
{
  echo "Usage: ${0} -s <Scheme> -o <Output Directory: default 'build'> -d <Framework Destination>"
}

while [[ $# -gt 0 ]]
do
  key=${1}
  case $key in
      -s)
      SCHEME=${2}
      shift
      ;;
      -o)
      OUTPUT_DIR=${2}
      shift
      ;;
      -d)
      DESTINATION_DIR=${2}
      shift
      ;;
      --quiet)
      QUIET="Y"
      ;;
      *)
      usage
      exit 3
      ;;
  esac
  shift
done

if [ -z "$SCHEME" ]
then
  usage
  exit 4
fi

CONFIGURATION="Release"
PLATFORM_NAME="ios"
SDKS=("iphoneos" "iphonesimulator")
PLATFORM_NAME="iOS"
WORKSPACE="Fritz.xcworkspace"
XCODEBUILD="xcodebuild"

if [ -z "$DESTINATION_DIR" ]
then
  DESTINATION_DIR="../swift-framework/Frameworks"
fi

if [ -z "$OUTPUT_DIR" ]
then
  OUTPUT_DIR="build"
fi


echo "Scheme: ${SCHEME}"
echo "Configuration : ${CONFIGURATION}"
echo "Platform: ${PLATFORM_NAME}"
echo "Output Directory: ${OUTPUT_DIR}"
echo "Destination Directory: ${DESTINATION_DIR}"


OUTPUT_BASE_DIR=${OUTPUT_DIR}/${SCHEME}/${PLATFORM_NAME}
OUTPUT_SIMULATOR_BASE_DIR=${OUTPUT_DIR}/${SCHEME}/${PLATFORM_NAME}/iphonesimulator
rm -rf "${OUTPUT_BASE_DIR}"

ROUND=0
OUTPUT_BINS=()
OUTPUT_SWIFT_MODULES=()


# Building all frameworks based on the SDK list:
for SDK in "${SDKS[@]}"
  do
    echo "Running xcodebuild on scheme=${SCHEME} configuration=${CONFIGURATION} and sdk=${SDK} ..."
    ACTION="build"
    if [[ ${ROUND} == 0 ]]
    then
      ACTION="clean build"
    fi

    # Adding "LD_VERIFY_BITCODE=NO" for an Xcode 11 Beta 4 bug.
    # Remove for new Xcode build version.
    ${XCODEBUILD} -workspace "${WORKSPACE}" -scheme "${SCHEME}" -configuration "${CONFIGURATION}" -sdk ${SDK} "ONLY_ACTIVE_ARCH=NO" "BITCODE_GENERATION_MODE=bitcode" "LD_VERIFY_BITCODE=NO" "CODE_SIGNING_REQUIRED=NO" "CODE_SIGN_IDENTITY=" ${ACTION} ${QUIET}
    ROUND=$((ROUND + 1))
done

TARGETS=( $(${XCODEBUILD} -workspace "${WORKSPACE}" -scheme ${SCHEME} -configuration ${CONFIGURATION} -showBuildSettings | grep TARGETNAME | awk '{print $3}') )
BUILD_ROOT=`${XCODEBUILD} -workspace "${WORKSPACE}" -scheme "${SCHEME}" -configuration "${CONFIGURATION}" -showBuildSettings|grep -w BUILD_ROOT|head -n 1|awk '{ print $3 }'`

for BIN_NAME in "${TARGETS[@]}"
do
    ROUND=0
    OUTPUT_BINS=()
    OUTPUT_SWIFT_MODULES=()
    # Get binary and framework name:
    FRAMEWORK_FILE_NAME=${BIN_NAME}.framework
    OUTPUT_FRAMEWORK_BUNDLE_DIR=${OUTPUT_BASE_DIR}/${FRAMEWORK_FILE_NAME}
    OUTPUT_SIMULATOR_BUNDLE_DIR=${OUTPUT_SIMULATOR_BASE_DIR}/${FRAMEWORK_FILE_NAME}

    for SDK in "${SDKS[@]}"
    do
        echo $BIN_NAME-$SDK

        # Get the XCode built framework file path:
        PRODUCTS_DIR=${BUILD_ROOT}/${CONFIGURATION}-${SDK}
        FRAMEWORK_FILE_PATH=${PRODUCTS_DIR}/${FRAMEWORK_FILE_NAME}

        # Create output dir to copy the built framework to:
        OUTPUT_SDK_DIR=${OUTPUT_BASE_DIR}/${SDK}
        mkdir -p "${OUTPUT_SDK_DIR}"

        # Copy the framework files:
        if [ ${ROUND} == 0 ]
        then
            cp -a "${FRAMEWORK_FILE_PATH}" "${OUTPUT_BASE_DIR}"
        fi

        cp -a "${FRAMEWORK_FILE_PATH}" "${OUTPUT_SDK_DIR}"

        # Collect output paths to use for making the FAT framework:
        OUTPUT_BINS+=("\"${OUTPUT_SDK_DIR}/${FRAMEWORK_FILE_NAME}/${BIN_NAME}\"")
        SWIFT_MODULE_DIR=${OUTPUT_SDK_DIR}/${FRAMEWORK_FILE_NAME}/Modules/${BIN_NAME}.swiftmodule
        if [ -d "${SWIFT_MODULE_DIR}" ]
        then
            OUTPUT_SWIFT_MODULES+=("${SWIFT_MODULE_DIR}")
        fi

        ROUND=$((ROUND + 1))
    done

    # Make FAT framework:
    if [[ ${#SDKS[@]} > 1 ]]
    then

        # Binary:
        LIPO_BIN_INPUTS=$(IFS=" " ; echo "${OUTPUT_BINS[*]}")
        echo "Generate FAT binary: ${LIPO_BIN_INPUTS}"
        LIPO_CMD="lipo ${LIPO_BIN_INPUTS} -create -output \"${OUTPUT_FRAMEWORK_BUNDLE_DIR}/${BIN_NAME}\""
        echo "${LIPO_CMD}"
        eval "${LIPO_CMD}"

        # Swift modules:
        for SWIFT_MODULE in "${OUTPUT_SWIFT_MODULES[@]}"
        do
            cp -a "${SWIFT_MODULE}/" "${OUTPUT_FRAMEWORK_BUNDLE_DIR}/Modules/${BIN_NAME}.swiftmodule/"
        done

        # Combine simulator and ios swift headers for Xcode 10.2 bug.
        # https://developer.apple.com/documentation/xcode_release_notes/xcode_10_2_release_notes
        SWIFT_HEADER_NAME=${BIN_NAME}-Swift.h
        SWIFT_HEADER_TMP_FILE=${OUTPUT_FRAMEWORK_BUNDLE_DIR}/Headers/${SWIFT_HEADER_NAME}.tmp
        SWIFT_HEADER_SIMULATOR_FILE=${OUTPUT_SIMULATOR_BUNDLE_DIR}/Headers/${SWIFT_HEADER_NAME}
        SWIFT_HEADER_IOS_FILE=${OUTPUT_FRAMEWORK_BUNDLE_DIR}/Headers/${SWIFT_HEADER_NAME}

        cat > $SWIFT_HEADER_TMP_FILE <<EOF
#if TARGET_OS_SIMULATOR
$(cat $SWIFT_HEADER_SIMULATOR_FILE)
#else
$(cat $SWIFT_HEADER_IOS_FILE)
#endif
EOF
        mv $SWIFT_HEADER_TMP_FILE $SWIFT_HEADER_IOS_FILE
        # Copy framework to destination
        rm -rf ${DESTINATION_DIR}/${BIN_NAME}*
        cp -R ${OUTPUT_FRAMEWORK_BUNDLE_DIR} ${DESTINATION_DIR}
    fi
done

# Cleanup build directory.
for SDK in "${SDKS[@]}"
  do
    rm -rf "${OUTPUT_BASE_DIR}/${SDK}"
done
