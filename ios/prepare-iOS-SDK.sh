#!/bin/sh
# CocoaPods invokes this via `set -e; ./prepare-iOS-SDK.sh`, which only guards the
# outer shell -- without our own `set -e` a failed clone exits 0 and leaves the pod
# with no xcframework, which surfaces much later as "Unable to find module 'SpotifyiOS'".
set -e

REPO_NAME="ios-sdk"
FRAMEWORK_NAME="SpotifyiOS.xcframework"
TAG="v5.0.1"

# prepare_command re-runs on every `pod install` for path-based (Flutter plugin) pods.
if [ -f "${REPO_NAME}/${FRAMEWORK_NAME}/Info.plist" ]; then
  exit 0
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

git clone --depth 1 --branch "${TAG}" "https://github.com/spotify/${REPO_NAME}" "${TMP_DIR}/src"

if [ ! -d "${TMP_DIR}/src/${FRAMEWORK_NAME}" ]; then
  echo "error: ${FRAMEWORK_NAME} missing from ${REPO_NAME}@${TAG}" >&2
  exit 1
fi

# Swap in only once the download is known-good, so a failed fetch cannot destroy a working copy.
rm -rf "${REPO_NAME}"
mkdir -p "${REPO_NAME}"
mv "${TMP_DIR}/src/${FRAMEWORK_NAME}" "${REPO_NAME}/"
