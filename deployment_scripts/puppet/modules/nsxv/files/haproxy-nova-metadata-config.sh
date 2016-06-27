#!/bin/bash
novaHaproxyConf="$(find /etc/haproxy/conf.d -name '*nova-metadata-api*')"
tempFile="$(mktemp)"

awk -v metadata_listen="$1" -v metadata_insecure="$2" -v metadata_crt_key_file="$3" '
{
  if ($1 == "bind") { next }
  if ($1 == "http-request") { next }
  print $0
}
END {
  if (metadata_insecure == "false") {
    print "  bind",metadata_listen,"ssl crt",metadata_crt_key_file,"no-sslv3 no-tls-tickets ciphers AES128+EECDH:AES128+EDH:AES256+EECDH:AES256+EDH"
    print "  http-request  set-header X-Forwarded-Proto https if { ssl_fc }"
  } else {
    print "  bind",metadata_listen
  }
} ' $novaHaproxyConf > $tempFile && mv -f $tempFile $novaHaproxyConf
