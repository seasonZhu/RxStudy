#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/AcknowList/3.1.0-6a066/dynamic_framework/AcknowList/Sled-Common-iphoneos/AcknowListBundle.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Alamofire/5.9.0-02b77/dynamic_framework/Alamofire/Sled-Common-iphoneos/Alamofire.bundle"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/App.storyboard"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_7z.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_7z@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_7z@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_aac.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_aac@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_aac@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_apk.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_apk@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_apk@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_avi.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_avi@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_avi@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bin.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bin@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bin@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bmp.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bmp@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_bmp@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_css.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_css@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_css@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dat.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dat@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dat@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_db.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_db@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_db@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_default.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_default@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_default@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dll.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dll@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dll@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dmg.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dmg@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_dmg@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_doc.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_doc@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_doc@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_eps.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_eps@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_eps@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_fla.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_fla@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_fla@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_flv.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_flv@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_flv@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_empty.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_empty@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_empty@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_not_empty.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_not_empty@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_folder_not_empty@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_gif.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_gif@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_gif@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_html.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_html@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_html@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ipa.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ipa@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ipa@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jar.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jar@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jar@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_java.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_java@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_java@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jpg.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jpg@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_jpg@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_js.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_js@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_js@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_json.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_json@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_json@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_keynote.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_keynote@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_keynote@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_md.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_md@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_md@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_midi.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_midi@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_midi@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mov.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mov@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mov@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp3.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp3@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp3@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp4.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp4@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mp4@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mpg.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mpg@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_mpg@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_numbers.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_numbers@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_numbers@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ogg.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ogg@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ogg@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pages.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pages@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pages@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pdf.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pdf@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_pdf@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_php.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_php@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_php@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_plist.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_plist@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_plist@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_png.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_png@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_png@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ppt.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ppt@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ppt@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_psd.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_psd@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_psd@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_sql.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_sql@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_sql@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_svg.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_svg@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_svg@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_swift.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_swift@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_swift@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_tif.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_tif@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_tif@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_torrent.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_torrent@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_torrent@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ttf.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ttf@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_ttf@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_txt.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_txt@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_txt@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wav.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wav@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wav@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wmv.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wmv@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_wmv@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xls.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xls@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xls@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xml.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xml@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_xml@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_zip.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_zip@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/FileType/icon_file_type_zip@3x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_app@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_bugs@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_close@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_down@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_logs@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_mail@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_network@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_sandbox@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/images/_icon_file_type_up@2x.png"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/Logs.storyboard"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/Manager.storyboard"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/Network.storyboard"
  install_resource "${PODS_ROOT}/CocoaDebug/Sources/Resources/NetworkCell.xib"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CocoaLumberjack/3.8.5-6a459/dynamic_framework/CocoaLumberjack-Core-Swift/Sled-Common-iphoneos/CocoaLumberjackPrivacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/IQKeyboardManagerSwift/7.0.2-d338c/dynamic_framework/IQKeyboardManagerSwift/Sled-Common-iphoneos/IQKeyboardManagerSwift.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KSCrash/1.17.0-593ec/dynamic_framework/17f28140fd4e0ea0401d982015295d3a/Sled-Common-iphoneos/KSCrashPrivacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Kingfisher/7.11.0-b9c98/dynamic_framework/Kingfisher/Sled-Common-iphoneos/Kingfisher.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/LifetimeTracker/1.8.3-e6764/dynamic_framework/LifetimeTracker/Sled-Common-iphoneos/LifetimeTracker.bundle"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/BarDashboard.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/CircularDashboard.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableView.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableViewCell.xib"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableViewHeaderView.xib"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MJRefresh/3.7.8-4e6e7/dynamic_framework/MJRefresh/Sled-Common-iphoneos/MJRefresh.Privacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MarqueeLabel/4.5.0-4b46d/dynamic_framework/MarqueeLabel/Sled-Common-iphoneos/MarqueeLabel.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/PrivacyInfo.xcprivacy"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SnapKit/5.7.1-d612e/dynamic_framework/SnapKit/Sled-Common-iphoneos/SnapKit_Privacy.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/AcknowList/3.1.0-6a066/dynamic_framework/AcknowList/Sled-Common-iphoneos/AcknowListBundle.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Alamofire/5.9.0-02b77/dynamic_framework/Alamofire/Sled-Common-iphoneos/Alamofire.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/CocoaLumberjack/3.8.5-6a459/dynamic_framework/CocoaLumberjack-Core-Swift/Sled-Common-iphoneos/CocoaLumberjackPrivacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/IQKeyboardManagerSwift/7.0.2-d338c/dynamic_framework/IQKeyboardManagerSwift/Sled-Common-iphoneos/IQKeyboardManagerSwift.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/KSCrash/1.17.0-593ec/dynamic_framework/17f28140fd4e0ea0401d982015295d3a/Sled-Common-iphoneos/KSCrashPrivacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/Kingfisher/7.11.0-b9c98/dynamic_framework/Kingfisher/Sled-Common-iphoneos/Kingfisher.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/LifetimeTracker/1.8.3-e6764/dynamic_framework/LifetimeTracker/Sled-Common-iphoneos/LifetimeTracker.bundle"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/BarDashboard.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/CircularDashboard.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableView.storyboard"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableViewCell.xib"
  install_resource "${PODS_ROOT}/LifetimeTracker/Sources/Resources/DashboardTableViewHeaderView.xib"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MJRefresh/3.7.8-4e6e7/dynamic_framework/MJRefresh/Sled-Common-iphoneos/MJRefresh.Privacy.bundle"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/MarqueeLabel/4.5.0-4b46d/dynamic_framework/MarqueeLabel/Sled-Common-iphoneos/MarqueeLabel.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/PrivacyInfo.xcprivacy"
  install_resource "${PODS_ROOT}/../../../../Library/Caches/CocoaPods/Frameworks/Release/SnapKit/5.7.1-d612e/dynamic_framework/SnapKit/Sled-Common-iphoneos/SnapKit_Privacy.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
