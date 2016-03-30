#!/bin/bash
metadata_listen_ip="$1"
metadata_listen_port='8775'
metadata_listen="$metadata_listen_ip:$metadata_listen_port"
novaHaproxyConf="$(find /etc/haproxy/conf.d -name '*nova-metadata-api*')"
tempFile="$(mktemp)"

awk -v metadata_listen="$metadata_listen" '
BEGIN {
  ipListen=0
}
{
  if ($1 == "bind") {
      if ($2 == metadata_listen) {
        ipListen=1
      }
  }
  print $0
}
END {
  if (ipListen == 0) {
    print "  bind",metadata_listen
  }

} ' $novaHaproxyConf > $tempFile && mv -f $tempFile $novaHaproxyConf
