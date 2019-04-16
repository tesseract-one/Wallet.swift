#!/bin/bash

set -e

HAS_CARGO_IN_PATH=`which cargo; echo $?`

if [ "$HAS_CARGO_IN_PATH" -ne "0" ]; then
    PATH="${HOME}/.cargo/bin:${PATH}"
fi

if [ -z "${PODS_TARGET_SRCROOT}" ]; then
    ROOT_DIR="${SRCROOT}/Keychain"
else
    ROOT_DIR="${PODS_TARGET_SRCROOT}/Keychain"
fi

OUTPUT_DIR=`echo "$CONFIGURATION" | tr '[:upper:]' '[:lower:]'`

cd "${ROOT_DIR}"/rust-keychain

cargo lipo --xcode-integ --manifest-path "keychain-c/Cargo.toml" --no-default-features --features "ethereum"

cp -f "${ROOT_DIR}"/rust-keychain/target/universal/"${OUTPUT_DIR}"/*.a "${ROOT_DIR}"/
cp -f "${ROOT_DIR}"/rust-keychain/keychain-c/include/*.h "${ROOT_DIR}"/

exit 0
