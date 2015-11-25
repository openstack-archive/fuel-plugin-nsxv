Configuration
=============

Switch to Settings tab of the Fuel web UI and click on NSXv plugin section,
tick the plugin checkbox to enable it.

.. image:: /image/nsxv-settings-filled.png
   :scale: 60 %

Several plugins input fields refer to MoRef ID (Managed Object Reference ID),
these are object IDs can be obtained via Managed Object Browser which is
located on the vCenter host, e.g. https://hostname.yourdomain.org/mob

Plugin contains the following settings:

#. NSX Manager hostname (or IP) -- if you are going to use hostname in this
   textbox be sure that your OpenStack controller will be able to resolve it.
   Add necessary DNS servers in *Host OS DNS Servers* section.  NSX Manager
   must be connected to vCenter server which you specified on VMware tab.

   OpenStack Controller must have L3 connectivity with NSX Manager through
   Public network.

#. NSX Manager user and password for access.

#. Datacenter MoRef ID -- ID of Datacenter where NSX Edge nodes will be
   deployed.

#. Cluster MoRef IDs for OpenStack VMs -- list of comma separated IDs of
   cluster where OpenStack VM instances will be launched.  You must obtain IDs
   for clusters that you specified on VMware tab.

#. Resource pool MoRef ID -- resource pool for NSX Edge nodes deployment.

#. Datastore MoRef ID -- datastore for NSX Edge nodes.

#. External portgroup -- portgroup through which NSX Edge nodes get
   connectivity with physical network

#. Transport zone MoRef ID -- transport zone for VXLAN logical networks.

   .. note::

      This ID can be fetched using NSX Manager API
      https://nsx-manager.yourdomain.org/api/2.0/vdn/scopes

#. Distributed virtual switch MoRef ID -- ID of vswitch connected to Edge
   cluster

#. NSX backup Edge pool -- size of NSX Edge nodes and size of Edge pool, value
   must follow format: <edge_type>:[edge_size]:<min_edges>:<max_edges>.

   **edge_type** can take the following values: *service* or *vdr* (service and
   distributed edge, respectively).

   NSX *service* nodes provide such services as DHCP, DNS, firewall, NAT, VPN,
   routing and load balancing.

   NSX *vdr* nodes performs distributed routing and bridging.

   **edge_size** can take following values: *compact*, *large* (default value if
   omitted), *xlarge*, *quadlarge*.

   **min_edges** and **max_edges** defines minimum and maximum amount of NSX
   Edge nodes in pool.

   Consider following table that describes NSX Edge types:

   ========= ===================
   Edge size Edge VM parameters
   ========= ===================
   compact   1 vCPU 512  MB vRAM
   large     2 vCPU 1024 MB vRAM
   quadlarge 4 vCPU 1024 MB vRAM
   xlarge    6 vCPU 8192 MB vRAM
   ========= ===================

   Consider following example values:

   ``service:compact:1:2,vdr:compact:1:3``

   ``service:xlarge:2:6,service:large:4:10,vdr:large:2:4``

#. Enable HA for NSX Edges -- if you enable this option NSX Edges will be
   deployed in active/standby pair on different ESXi hosts.

#. Bypass NSX Manager certificate verification -- disable this option if you
   want Neutron NSX plugin to verify NSX Manager security certificate. *CA
   certificate file* setting will appear providing an option to upload
   CA certificate which emitted NSX Manager certificate.

To enable Nova metadata service, set the following settings must be set:

#. Metadata portgroup MoRef ID -- portgroup MoRef ID for metadata proxy service

#. Metadata proxy IP addresses -- comma separated IP addresses used by Nova
   metadata proxy service.

#. Management network netmask -- management network netmask for metadata proxy
   service.

#. Management network default gateway -- management network gateway for
   metadata proxy service.

If you tick *Additional settings* checkbox following options will become
available for configuration:

#. Task status check interval -- asynchronous task status check interval,
   default is 2000 (millisecond).

#. Maximum tunnels per vnic -- specify maximum amount of tunnels per vnic,
   possible range of values 1-110 (20 is used if no other value is provided).

#. API retries -- maximum number of API retries (10 by default)

#. Enable SpoofGuard -- option allows to control behaviour of port-security
   feature that prevents traffic flow if IP address of VM that was reported by
   VMware Tools does not match source IP address that is observed in outgoing
   VM traffic (consider the case when VM was compromised).

#. Tenant router types -- ordered list of preferred tenant router types (default
   value is 'shared, distributed, exclusive').
