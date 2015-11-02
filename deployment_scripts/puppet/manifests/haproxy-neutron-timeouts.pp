# Default haproxy timeouts are too small and neuton CLI client receive 504
# error (gateway timeout) from haproxy. We are increasing timeouts for neutron
# backend to avoid this.

$nsx_timeouts = "  timeout client 600s\n  timeout client-fin 30s\n  timeout server 600s\n  timeout server-fin 30s\n"

file_line { 'neutron-nsxv-timeouts':
  path   => '/etc/haproxy/conf.d/085-neutron.cfg',
  after  => '^listen\s+neutron$',
  line   => $nsx_timeouts,
}
