#!/bin/bash
URL="https://s3.amazonaws.com/tunnelbear/linux/openvpn.zip"
TPL="template"
TMP="tmp"
SERVERS_SRC="$TPL/servers.zip"
SERVERS_DST="$TPL/servers.csv"
CA="$TPL/ca.crt"
CLIENT="$TPL/client.crt"
CLIENT_KEY="$TPL/client.key"

mkdir -p $TPL
curl -L $URL >$SERVERS_SRC
rm -rf $TMP
unzip $SERVERS_SRC -d $TMP

mv $TMP/openvpn/CACertificate.crt $CA
openssl x509 -in $TMP/openvpn/UserCertificate.crt -out $CLIENT # strip text header
mv $TMP/openvpn/PrivateKey.key $CLIENT_KEY

grep ^remote $TMP/openvpn/*.ovpn | sed -E "s/^.*TunnelBear\ ([^\.]+)\.ovpn:remote ([A-Za-z0-9\-_]+)\.([A-Za-z0-9\.]+).*443.*$/\1,\2,\2.\3/" >$SERVERS_DST
