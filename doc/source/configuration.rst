Configuration
=============

Switch to Settings tab and click on NSXv plugin section, tick the plugin
checkbox to enable it.

.. image:: /image/nsxv-settings-filled.png
   :scale: 60 %

Several plugins input fields refer to MoRef ID (Managed Object Reference ID),
these are object IDs can be obtained via Managed Object Browser which is
located on the vCenter host, e.g. https://hostname.yourdomain.org/mob

Plugin contains following settings:

* NSX Manager hostname (or IP) -- if you are going to use hostname in this
  textbox be sure that your OpenStack controller will be able to resolve it.
  Add necessary DNS servers in 'Host OS DNS Servers' section.  NSX Manager must
  be connected to vCenter server which you specified on VMware tab.

  OpenStack Controller must have L3 connectivity with NSX Manager through
  Public network.

* NSX Manager user and password for access.

* Datacenter MoRef ID -- ID of Datacenter where NSX Edge nodes will be
  deployed.

* Cluster MoRef IDs for OpenStack VMs -- list of comma separated IDs of cluster
  where OpenStack VM instances will be launched.  You must obtain IDs for
  clusters that you specified on VMware tab.

* Resource pool MoRef ID -- resource pool for NSX Edge nodes.

* Datastore MoRef ID -- datastore for NSX Edge nodes.

* Extern portgroup -- portgroup through which NSX Edge nodes get connectivity
  with physical network

* Transport zone MoRef ID -- transport zone for VXLAN logical networks

* Distributed virtual switch MoRef ID -- ID of vswitch connected to Edge
  cluster

* NSX backup Edge pool -- size of NSX Edge nodes and size of Edge pool, value
  must follow format: <edge_type>:[edge_size]:<min_edges>:<max_edges>.

  **edge_type** can take following values: *service* or *vdr* (service and
  distributed edge, respectively).

  **edge_size** can take following values: *compact*, *large* (default value if
  ommited), *xlarge*, *quadlarge*.

  **min_edges** and **max_edges** defines minimum and maximum amount of NSX
  Edge nodes in pool.

  Consider following table that describes NSX Edge types:

  ========= ===================
  Edge size Edge VM parameters
  ========= ===================
  compact   1 vCPU 512  MB vRAM
  large     2 vCPU 2014 MB vRAM
  xlarge    4 vCPU 1024 MB vRAM
  quadlarge 6 vCPU 8192 MB vRAM
  ========= ===================

* Enable HA for NSX Edges -- if you enable this option NSX Edges will deployed
  in active/standby pair on different ESXi hosts.

* Bypass NSX Manager certificate verification -- disable this option if you
  want Neutron NSX plugin to verify NSX Manager security certificate. *CA
  certificate file* setting will appear providing an option to upload
  CA certificate which emitted NSX Manager certificate.

