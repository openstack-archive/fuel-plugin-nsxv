#!/bin/bash
neutronHaproxyConf="$(find /etc/haproxy/conf.d -name '*neutron*')"
tempFile="$(mktemp)"

awk '
BEGIN {
firstServer=1
}
{
  if ($1 == "server") {
      if (firstServer == 1) {
        firstServer = 0
        print $0
      }
      else {
        if ($NF != "backup") {
          print $0,"backup"
        } else {
          print $0
        }
      }
  } else {
    if ( $1 == "timeout" && $2 == "client" ) { next }
    if ( $1 == "timeout" && $2 == "client-fin" ) { next }
    if ( $1 == "timeout" && $2 == "server" ) { next }
    if ( $1 == "timeout" && $2 == "server-fin" ) { next }
    print $0
  }
}
END {
  print "  timeout  client 600s"
  print "  timeout  client-fin 30s"
  print "  timeout  server 600s"
  print "  timeout  server-fin 30s"
} ' $neutronHaproxyConf > $tempFile && mv -f $tempFile $neutronHaproxyConf
