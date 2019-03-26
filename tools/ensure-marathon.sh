#!/bin/sh
source .tools/ensure-mint.sh

WHICH_CMD=`which marathon`

if [ ! -f "${WHICH_CMD}" ]; then
  mint install JohnSundell/Marathon
fi
