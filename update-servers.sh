#!/bin/bash
URL="https://s3.amazonaws.com/tunnelbear/linux/openvpn.zip"
TPL="template"
TMP="tmp"
SERVERS_SRC="$TPL/servers.zip"
SERVERS_DST="$TPL/servers.csv"
CA="$TPL/ca.crt"
CLIENT="$TPL/client.crt"
CLIENT_KEY="$TPL/client.key"

rm -rf $TMP
mkdir -p $TPL
mkdir -p $TMP
if ! curl -L $URL >$SERVERS_SRC.tmp; then
    exit
fi
mv $SERVERS_SRC.tmp $SERVERS_SRC
unzip $SERVERS_SRC -d $TMP

mv $TMP/openvpn/CACertificate.crt $CA
openssl x509 -in $TMP/openvpn/UserCertificate.crt -out $CLIENT # strip text header
mv $TMP/openvpn/PrivateKey.key $CLIENT_KEY

grep ^remote $TMP/openvpn/*.ovpn | sed -E "s/^.*TunnelBear\ ([^\.]+)\.ovpn:remote ([A-Za-z0-9_-]+)\.([A-Za-z0-9\.]+).*443.*$/\1,\2,\2.\3/" >$SERVERS_DST
sed -i"" -E "s/,uk,/,gb,/g" $SERVERS_DST
