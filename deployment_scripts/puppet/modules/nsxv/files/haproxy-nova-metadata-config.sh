#!/bin/bash
novaHaproxyConf="$(find /etc/haproxy/conf.d -name '*nova-metadata-api*')"
tempFile="$(mktemp)"

awk -v metadata_listen="$1" '
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
