#!/bin/sh
# ref: https://www.createwithswift.com/publishing-docc-documention-as-a-static-website-on-github-pages/

DERIVED_DATA_DIR=/tmp/derived_data
DOARCHIVE=${DERIVED_DATA_DIR}/Build/Products/Debug/PacketProcessor.doccarchive
OUTPUT_DIR="docs"
BASE_URL="SwiftPacketProcessor/"

xcodebuild docbuild \
    -scheme PacketProcessor \
    -derivedDataPath "${DERIVED_DATA_DIR}" \
    -destination 'platform=macOS'

$(xcrun --find docc) process-archive \
    transform-for-static-hosting "${DOARCHIVE}" \
    --output-path "${OUTPUT_DIR}" \
    --hosting-base-path "${BASE_URL}"

