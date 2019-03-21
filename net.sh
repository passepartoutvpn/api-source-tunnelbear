#!/bin/sh
cd `dirname $0`
scripts/update-servers.sh >/dev/null
ruby scripts/net.rb $*
