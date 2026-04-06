#!/bin/bash

set -e

. /scripts/env.sh

CORE_REPO="https://github.com/KMFDManic/mame2003-xtreme"
CORE_NAME="km_mame2003_xtreme_amped"

echo "Building: $CORE_NAME"
cd /tmp
git clone "$CORE_REPO.git" "$CORE_NAME"
cd "$CORE_NAME"

make -j$(nproc)

cp "/tmp/$CORE_NAME/${CORE_NAME}_libretro.so" /output/cores
cp "/tmp/$CORE_NAME/info/${CORE_NAME}_libretro.info" /output/core_info/
rm -rf "/tmp/$CORE_NAME"
echo "Done!"
