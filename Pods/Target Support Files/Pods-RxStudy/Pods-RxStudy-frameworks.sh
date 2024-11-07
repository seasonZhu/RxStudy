#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${FRAMEWORKS_FOLDER_PATH+x} ]; then
  # If FRAMEWORKS_FOLDER_PATH is not set, then there's nowhere for us to copy
  # frameworks to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

COCOAPODS_PARALLEL_CODE_SIGN="${COCOAPODS_PARALLEL_CODE_SIGN:-false}"
SWIFT_STDLIB_PATH="${TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"
BCSYMBOLMAP_DIR="BCSymbolMaps"


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

# Copies and strips a vendored framework
install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
    echo "Symlinked..."
    source="$(readlink -f "${source}")"
  fi

  if [ -d "${source}/${BCSYMBOLMAP_DIR}" ]; then
    # Locate and install any .bcsymbolmaps if present, and remove them from the .framework before the framework is copied
    find "${source}/${BCSYMBOLMAP_DIR}" -name "*.bcsymbolmap"|while read f; do
      echo "Installing $f"
      install_bcsymbolmap "$f" "$destination"
      rm "$f"
    done
    rmdir "${source}/${BCSYMBOLMAP_DIR}"
  fi

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"

  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  elif [ -L "${binary}" ]; then
    echo "Destination binary is symlinked..."
    dirname="$(dirname "${binary}")"
    binary="${dirname}/$(readlink "${binary}")"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u)
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}
# Copies and strips a vendored dSYM
install_dsym() {
  local source="$1"
  warn_missing_arch=${2:-true}
  if [ -r "$source" ]; then
    # Copy the dSYM into the targets temp dir.
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${DERIVED_FILES_DIR}\""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${DERIVED_FILES_DIR}"

    local basename
    basename="$(basename -s .dSYM "$source")"
    binary_name="$(ls "$source/Contents/Resources/DWARF")"
    binary="${DERIVED_FILES_DIR}/${basename}.dSYM/Contents/Resources/DWARF/${binary_name}"

    # Strip invalid architectures from the dSYM.
    if [[ "$(file "$binary")" == *"Mach-O "*"dSYM companion"* ]]; then
      strip_invalid_archs "$binary" "$warn_missing_arch"
    fi
    if [[ $STRIP_BINARY_RETVAL == 0 ]]; then
      # Move the stripped file into its final destination.
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${DERIVED_FILES_DIR}/${basename}.framework.dSYM\" \"${DWARF_DSYM_FOLDER_PATH}\""
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${DERIVED_FILES_DIR}/${basename}.dSYM" "${DWARF_DSYM_FOLDER_PATH}"
    else
      # The dSYM was not stripped at all, in this case touch a fake folder so the input/output paths from Xcode do not reexecute this script because the file is missing.
      mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
      touch "${DWARF_DSYM_FOLDER_PATH}/${basename}.dSYM"
    fi
  fi
}

# Used as a return value for each invocation of `strip_invalid_archs` function.
STRIP_BINARY_RETVAL=0

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  warn_missing_arch=${2:-true}
  # Get architectures for current target binary
  binary_archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | awk '{$1=$1;print}' | rev)"
  # Intersect them with the architectures we are building for
  intersected_archs="$(echo ${ARCHS[@]} ${binary_archs[@]} | tr ' ' '\n' | sort | uniq -d)"
  # If there are no archs supported by this binary then warn the user
  if [[ -z "$intersected_archs" ]]; then
    if [[ "$warn_missing_arch" == "true" ]]; then
      echo "warning: [CP] Vendored binary '$binary' contains architectures ($binary_archs) none of which match the current build architectures ($ARCHS)."
    fi
    STRIP_BINARY_RETVAL=1
    return
  fi
  stripped=""
  for arch in $binary_archs; do
    if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary"
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
  STRIP_BINARY_RETVAL=0
}

# Copies the bcsymbolmap files of a vendored framework
install_bcsymbolmap() {
    local bcsymbolmap_path="$1"
    local destination="${BUILT_PRODUCTS_DIR}"
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${bcsymbolmap_path}" "${destination}""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${bcsymbolmap_path}" "${destination}"
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" -a "${CODE_SIGNING_REQUIRED:-}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identity
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    local code_sign_cmd="/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS:-} --preserve-metadata=identifier,entitlements '$1'"

    if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
      code_sign_cmd="$code_sign_cmd &"
    fi
    echo "$code_sign_cmd"
    eval "$code_sign_cmd"
  fi
}

if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/AcknowList/3.1.0-6a066/dynamic_framework/AcknowList/Sled-Common-iphoneos/AcknowList.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Alamofire/5.9.0-02b77/dynamic_framework/Alamofire/Sled-Common-iphoneos/Alamofire.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CocoaDebug/1.7.7-b38d3/dynamic_framework/CocoaDebug/Sled-Common-iphoneos/CocoaDebug.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CocoaLumberjack/3.8.5-6a459/dynamic_framework/CocoaLumberjack-Core-Swift/Sled-Common-iphoneos/CocoaLumberjack.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CombineCocoa/0.4.1-e5210/dynamic_framework/CombineCocoa/Sled-Common-iphoneos/CombineCocoa.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CombineExt/1.8.0-c4daa/dynamic_framework/CombineExt/Sled-Common-iphoneos/CombineExt.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/DZNEmptyDataSet/1.8.1-95258/dynamic_framework/DZNEmptyDataSet/Sled-Common-iphoneos/DZNEmptyDataSet.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Differentiator/5.0.0-e8497/dynamic_framework/Differentiator/Sled-Common-iphoneos/Differentiator.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/FBRetainCycleDetector/0.1.4-46f81/dynamic_framework/FBRetainCycleDetector/Sled-Common-iphoneos/FBRetainCycleDetector.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/FSPagerView/0.8.3-67040/dynamic_framework/FSPagerView/Sled-Common-iphoneos/FSPagerView.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/FunnyButton/0.1.5-e8202/dynamic_framework/FunnyButton/Sled-Common-iphoneos/FunnyButton.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/IQKeyboardManagerSwift/7.0.2-d338c/dynamic_framework/IQKeyboardManagerSwift/Sled-Common-iphoneos/IQKeyboardManagerSwift.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/JXSegmentedView/1.3.0-fec0d/dynamic_framework/JXSegmentedView/Sled-Common-iphoneos/JXSegmentedView.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KSCrash/1.17.0-593ec/dynamic_framework/17f28140fd4e0ea0401d982015295d3a/Sled-Common-iphoneos/KSCrash.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KeychainAccess/4.2.2-c0c4f/dynamic_framework/KeychainAccess/Sled-Common-iphoneos/KeychainAccess.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Kingfisher/7.11.0-b9c98/dynamic_framework/Kingfisher/Sled-Common-iphoneos/Kingfisher.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/LifetimeTracker/1.8.3-e6764/dynamic_framework/LifetimeTracker/Sled-Common-iphoneos/LifetimeTracker.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/LookinServer/1.2.7-36f1a/dynamic_framework/LookinServer-Core/Sled-Common-iphoneos/LookinServer.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MBProgressHUD/1.2.0-3ee5e/dynamic_framework/MBProgressHUD/Sled-Common-iphoneos/MBProgressHUD.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MJRefresh/3.7.8-4e6e7/dynamic_framework/MJRefresh/Sled-Common-iphoneos/MJRefresh.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MLeaksFinder/1.0.0-8c435/dynamic_framework/MLeaksFinder/Sled-Common-iphoneos/MLeaksFinder.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MarqueeLabel/4.5.0-4b46d/dynamic_framework/MarqueeLabel/Sled-Common-iphoneos/MarqueeLabel.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Moya/15.0.0-138f0/dynamic_framework/Moya-Combine-Core-RxSwift/Sled-Common-iphoneos/Moya.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/NSObject+Rx/5.2.2-61cf1/dynamic_framework/NSObject+Rx/Sled-Common-iphoneos/NSObject_Rx.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/R.swift/7.3.2-0af0d/dynamic_framework/R.swift/Sled-Common-iphoneos/RswiftResources.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxBlocking/6.6.0-fbd1f/dynamic_framework/RxBlocking/Sled-Common-iphoneos/RxBlocking.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxCocoa/6.6.0-44a80/dynamic_framework/RxCocoa/Sled-Common-iphoneos/RxCocoa.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxDataSources/5.0.0-aa47c/dynamic_framework/RxDataSources/Sled-Common-iphoneos/RxDataSources.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxGesture/4.0.4-f3efb/dynamic_framework/RxGesture/Sled-Common-iphoneos/RxGesture.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxOptional/5.0.2-36649/dynamic_framework/RxOptional/Sled-Common-iphoneos/RxOptional.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxRelay/6.6.0-45eaa/dynamic_framework/RxRelay/Sled-Common-iphoneos/RxRelay.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxSwift/6.6.0-a4b44/dynamic_framework/RxSwift/Sled-Common-iphoneos/RxSwift.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxSwiftExt/6.2.1-43aaa/dynamic_framework/RxSwiftExt-Core-RxCocoa/Sled-Common-iphoneos/RxSwiftExt.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxTheme/6.0.0-be60c/dynamic_framework/RxTheme/Sled-Common-iphoneos/RxTheme.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxViewController/2.0.0-56486/dynamic_framework/RxViewController/Sled-Common-iphoneos/RxViewController.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SFSafeSymbols/5.2.0-dc465/dynamic_framework/SFSafeSymbols/Sled-Common-iphoneos/SFSafeSymbols.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SSZipArchive/2.4.3-fe6a2/dynamic_framework/SSZipArchive/Sled-Common-iphoneos/SSZipArchive.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SVProgressHUD/2.3.1-4837c/dynamic_framework/SVProgressHUD-Core/Sled-Common-iphoneos/SVProgressHUD.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SnapKit/5.7.1-d612e/dynamic_framework/SnapKit/Sled-Common-iphoneos/SnapKit.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SwiftDate/7.0.0-bbc26/dynamic_framework/SwiftDate/Sled-Common-iphoneos/SwiftDate.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/AcknowList/3.1.0-6a066/dynamic_framework/AcknowList/Sled-Common-iphoneos/AcknowList.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Alamofire/5.9.0-02b77/dynamic_framework/Alamofire/Sled-Common-iphoneos/Alamofire.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CocoaLumberjack/3.8.5-6a459/dynamic_framework/CocoaLumberjack-Core-Swift/Sled-Common-iphoneos/CocoaLumberjack.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CombineCocoa/0.4.1-e5210/dynamic_framework/CombineCocoa/Sled-Common-iphoneos/CombineCocoa.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CombineExt/1.8.0-c4daa/dynamic_framework/CombineExt/Sled-Common-iphoneos/CombineExt.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/DZNEmptyDataSet/1.8.1-95258/dynamic_framework/DZNEmptyDataSet/Sled-Common-iphoneos/DZNEmptyDataSet.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Differentiator/5.0.0-e8497/dynamic_framework/Differentiator/Sled-Common-iphoneos/Differentiator.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/FBRetainCycleDetector/0.1.4-46f81/dynamic_framework/FBRetainCycleDetector/Sled-Common-iphoneos/FBRetainCycleDetector.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/FSPagerView/0.8.3-67040/dynamic_framework/FSPagerView/Sled-Common-iphoneos/FSPagerView.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/IQKeyboardManagerSwift/7.0.2-d338c/dynamic_framework/IQKeyboardManagerSwift/Sled-Common-iphoneos/IQKeyboardManagerSwift.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/JXSegmentedView/1.3.0-fec0d/dynamic_framework/JXSegmentedView/Sled-Common-iphoneos/JXSegmentedView.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KSCrash/1.17.0-593ec/dynamic_framework/17f28140fd4e0ea0401d982015295d3a/Sled-Common-iphoneos/KSCrash.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KeychainAccess/4.2.2-c0c4f/dynamic_framework/KeychainAccess/Sled-Common-iphoneos/KeychainAccess.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Kingfisher/7.11.0-b9c98/dynamic_framework/Kingfisher/Sled-Common-iphoneos/Kingfisher.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/LifetimeTracker/1.8.3-e6764/dynamic_framework/LifetimeTracker/Sled-Common-iphoneos/LifetimeTracker.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MBProgressHUD/1.2.0-3ee5e/dynamic_framework/MBProgressHUD/Sled-Common-iphoneos/MBProgressHUD.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MJRefresh/3.7.8-4e6e7/dynamic_framework/MJRefresh/Sled-Common-iphoneos/MJRefresh.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MarqueeLabel/4.5.0-4b46d/dynamic_framework/MarqueeLabel/Sled-Common-iphoneos/MarqueeLabel.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Moya/15.0.0-138f0/dynamic_framework/Moya-Combine-Core-RxSwift/Sled-Common-iphoneos/Moya.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/NSObject+Rx/5.2.2-61cf1/dynamic_framework/NSObject+Rx/Sled-Common-iphoneos/NSObject_Rx.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/R.swift/7.3.2-0af0d/dynamic_framework/R.swift/Sled-Common-iphoneos/RswiftResources.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxBlocking/6.6.0-fbd1f/dynamic_framework/RxBlocking/Sled-Common-iphoneos/RxBlocking.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxCocoa/6.6.0-44a80/dynamic_framework/RxCocoa/Sled-Common-iphoneos/RxCocoa.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxDataSources/5.0.0-aa47c/dynamic_framework/RxDataSources/Sled-Common-iphoneos/RxDataSources.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxGesture/4.0.4-f3efb/dynamic_framework/RxGesture/Sled-Common-iphoneos/RxGesture.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxOptional/5.0.2-36649/dynamic_framework/RxOptional/Sled-Common-iphoneos/RxOptional.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxRelay/6.6.0-45eaa/dynamic_framework/RxRelay/Sled-Common-iphoneos/RxRelay.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxSwift/6.6.0-a4b44/dynamic_framework/RxSwift/Sled-Common-iphoneos/RxSwift.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxSwiftExt/6.2.1-43aaa/dynamic_framework/RxSwiftExt-Core-RxCocoa/Sled-Common-iphoneos/RxSwiftExt.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxTheme/6.0.0-be60c/dynamic_framework/RxTheme/Sled-Common-iphoneos/RxTheme.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/RxViewController/2.0.0-56486/dynamic_framework/RxViewController/Sled-Common-iphoneos/RxViewController.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SFSafeSymbols/5.2.0-dc465/dynamic_framework/SFSafeSymbols/Sled-Common-iphoneos/SFSafeSymbols.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SSZipArchive/2.4.3-fe6a2/dynamic_framework/SSZipArchive/Sled-Common-iphoneos/SSZipArchive.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SVProgressHUD/2.3.1-4837c/dynamic_framework/SVProgressHUD-Core/Sled-Common-iphoneos/SVProgressHUD.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SnapKit/5.7.1-d612e/dynamic_framework/SnapKit/Sled-Common-iphoneos/SnapKit.framework"
  install_framework "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SwiftDate/7.0.0-bbc26/dynamic_framework/SwiftDate/Sled-Common-iphoneos/SwiftDate.framework"
fi
if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
  wait
fi
