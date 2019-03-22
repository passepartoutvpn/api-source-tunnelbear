#!/bin/bash
mkdir template
curl -L "https://s3.amazonaws.com/tunnelbear/linux/openvpn.zip" >template/src.zip
rm -rf tmp
unzip template/src.zip -d tmp

mkdir certs
mv tmp/openvpn/CACertificate.crt certs/ca.pem
openssl x509 -in tmp/openvpn/UserCertificate.crt -out certs/client.pem # strip text header
mv tmp/openvpn/PrivateKey.key certs/client.key

grep ^remote tmp/openvpn/*.ovpn | sed -E "s/^.*TunnelBear\ ([^\.]+)\.ovpn:remote ([[A-Za-z0-9\.]+).*443.*$/\1,\2/" >template/servers.csv

rm -rf tmp
