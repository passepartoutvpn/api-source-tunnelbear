#!/bin/bash
URL="https://www.tunnelbear.com/"
TPL="template"
SERVERS_DST="$TPL/servers.html"

mkdir -p $TPL
if ! curl -L $URL >$SERVERS_DST.tmp; then
    exit 1
fi
mv $SERVERS_DST.tmp $SERVERS_DST
