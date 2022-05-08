#!/bin/sh
# ref: https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/
# ref: https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/generating-documentation-for-hosting-online

DERIVED_DATA_DIR=/tmp/derived_data
DOARCHIVE=${DERIVED_DATA_DIR}/Build/Products/Debug/PacketProcessor.doccarchive
OUTPUT_DIR="docs"
BASE_URL="SwiftPacketProcessor/"
BUILD_TARGET="PacketProcessor"


swift package --allow-writing-to-directory "${OUTPUT_DIR}" \
    generate-documentation --target "${BUILD_TARGET}" \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path "${BASE_URL}" \
    --output-path "${OUTPUT_DIR}"


mv docs/index.html ${DERIVED_DATA_DIR}/index.html
cat ${DERIVED_DATA_DIR}/index.html | sed 's/"\//"\/SwiftPacketProcessor\//g' > docs/index.html
