#!/bin/sh

WHICH_CMD=`which mint`

if [ ! -f "${WHICH_CMD}" ]; then
  brew install mint
fi
