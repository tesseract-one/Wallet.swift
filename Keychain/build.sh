#!/bin/bash

set -e

HAS_CARGO_IN_PATH=`which cargo; echo $?`

if [ "$HAS_CARGO_IN_PATH" -ne "0" ]; then
    PATH="${HOME}/.cargo/bin:${PATH}"
fi

cd "${SRCROOT}"/Keychain/rust-keychain

cargo lipo --release --package tesseract-keychain-c --no-default-features --features "ethereum"

cp -f "${SRCROOT}"/Keychain/rust-keychain/target/universal/release/*.a "${SRCROOT}"/Keychain/
cp -f "${SRCROOT}"/Keychain/rust-keychain/keychain-c/include/*.h "${SRCROOT}"/Keychain/

exit 0
