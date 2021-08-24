#!/bin/bash

USE="usage all Certificates:
       $(basename "$0") </path/to> </dest/path>

       </path/to -> acme.json> -> without - acme.json
       </dest/path> -> output directory

usage 1,2.. Certificates:
       $(basename "$0") </path/to> </dest/path> <sub.domain.de>

       </path/to -> acme.json> -> without - acme.json
       </dest/path> -> output directory
       <sub.domain.de> -> single - sub.domain.de or multi - seperated by ',' sub.domain.de,sub2.domain.de,...\n"

function exit_jq {
echo -e "
You must have the binary 'jq' to use this.
jq is available at: https://stedolan.github.io/jq/download/
or in Debian etc.:
use: apt install jq

$USE"
exit
}

function bad_acme {
echo -e "
There was a problem problem your acme.json file.

$USE"
exit
}

function bad_certs {
echo -e "
Are your certs correct ?
seperated by ',' ?
You are looking for:
certs = $self"
#$USE"
exit
}

function dest {
#echo "Pfad nach acme.json = $1"
#echo "destination path = $2"
ordner=${1%/}
ordner1=${2%/}

if [ ! -d $ordner1 ];then
mkdir -p $ordner1
fi
}

function priv_key {
priv=$(jq -e -r '.[].Account.PrivateKey' $ordner/acme.json) || bad_acme
if [ ! -n "${priv}" ]; then
echo "
There didn't seem to be a private key in $ordner/acme.json.
Please ensure that there is a key in this file and try again." >&2
exit
fi
echo -e "-----BEGIN RSA PRIVATE KEY-----\n${priv}\n-----END RSA PRIVATE KEY-----" \
   | openssl rsa -inform pem -out $ordner1/private.key
}

function certer {
pcert=$(jq -e -r --arg acme "$acme" '.[].Certificates[] | select(.domain.main==$acme) | .certificate' $ordner/acme.json | base64 -d > $ordner1/$acme1/$acme.pem) || bad_certs
sed -i '/^$/d' $ordner1/$acme1/$acme.pem

cers=($(grep -ni "BEGIN CERTIFICATE" $ordner1/$acme1/$acme.pem | cut -d: -f1))
cere=($(grep -ni "END CERTIFICATE" $ordner1/$acme1/$acme.pem | cut -d: -f1))

as=$((${#cers[@]}-1))
ase=$((${#cere[@]}-2))
ae=$((${#cere[@]}-1))

# O.K. cert
cat $ordner1/$acme1/$acme.pem | sed -n "${cers[0]},${cere[0]}p" > $ordner1/$acme1/cert.pem || bad_certs
# O.K. chain
cat $ordner1/$acme1/$acme.pem | sed -n "${cers[1]},${cere[$ae]}p" > $ordner1/$acme1/chain.pem || bad_certs
# O.K. fullchain
#cat $ordner1/$acme1/cert.pem $ordner1/$acme1/chain.pem > $ordner1/$acme1/fullchain.pem
mv $ordner1/$acme1/$acme.pem $ordner1/$acme1/fullchain.pem || bad_certs

# now O.K. key
pkey=$(jq -e -r --arg acme "$acme" '.[].Certificates[] | select(.domain.main==$acme) | .key' $ordner/acme.json | base64 -d > $ordner1/$acme1/privkey.pem) || bad_certs
}

# --- Main --- #

jq=$(command -v jq) || exit_jq

if [ $# -lt 2 -o $# -gt 3 ];then
echo -e "
Wrong number of parameters.
$USE"
exit

elif [ ! -f ${1%/}/acme.json ];then
bad_acme
exit

# all certificates
elif [ $# -eq 2 -a -f ${1%/}/acme.json ];then
#echo "acme.json exist"
#echo "There are $# arguments"
dest $1 $2
anz=$(jq '.[].Certificates | length' $ordner/acme.json)
echo "There are $anz Certificate"
priv_key $ordner $ordner1

for ((i=0; i<$anz; i++))
do
acme=$(jq -r '.[].Certificates['$i'].domain.main' $ordner/acme.json)
acme1=$(jq -r '.[].Certificates['$i'].domain.main' $ordner/acme.json | cut -d. -f1)
echo "Makedir Ordner $acme1"
mkdir -p $ordner1/$acme1
certer $ordner1 $acme $acme1
done
exit

# selected certificates
elif [ $# -eq 3 -a -f ${1%/}/acme.json ];then
#echo "acme.json exist"
#echo "There are $# arguments"
dest $1 $2
self=$3
echo "Looking for $3"
sub=$(echo $self | tr ',' ' ')
acm=($sub)
anz="${#acm[@]}"
echo "There are $anz Certificate"
priv_key $ordner $ordner1

for ((i=0; i<$anz; i++))
do
acme=$(echo "${acm[$i]}")
#echo $acme
acme1=$(echo "${acm[$i]}" | cut -d. -f1)
echo "Makedir Ordner $acme1"
mkdir -p $ordner1/$acme1
certer $self $ordner1 $acme $acme1
done
exit

fi
