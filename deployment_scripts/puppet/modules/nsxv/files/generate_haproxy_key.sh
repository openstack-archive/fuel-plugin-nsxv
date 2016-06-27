#!/bin/sh
crt_key_file="$1"
cn='metadata.nsx.local'
cert_gen_dir="$(mktemp -d)"
key_path="$cert_gen_dir/$cn.key"
crt_path="$cert_gen_dir/$cn.crt"

mkdir -p "$(dirname $crt_key_file)"
if [ ! -f $crt_key_file ]; then
  bash -c "openssl req -newkey rsa:2048 -nodes -keyout $key_path -x509 -days 3650 -subj /C=US/ST=State/L=Locality/O=Organization/OU=Unit/CN=$cn/emailAddress=root@$cn -out $crt_path 2>&1"
  cat "$crt_path" "$key_path" > $crt_key_file
  chown root:root $crt_key_file
  chmod 600 $crt_key_file
else
  echo "Key $crt_key_file already exists"
fi
rm -fr "${cert_gen_dir:?}"
