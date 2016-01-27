#! /usr/bin/awk -f
BEGIN { firstServer=1 }
{
if ($0 ~ /^\s+server/)
  {
    if (firstServer == 1) {
      firstServer = 0
      print $0 }
    else
      print $0,"backup"
  }
else
  print $0
}
