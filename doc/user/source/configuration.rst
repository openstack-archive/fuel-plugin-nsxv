Configuration
=============

Switch to Networks tab of the Fuel web UI and click on *Settings*/*Other*
section, the plugin checkbox enabled by default. For reasons of clarity not all
settings are shown on the screenshot below:

.. image:: /image/nsxv-settings-filled.png
   :scale: 60 %

Several plugin input fields refer to MoRef ID (Managed Object Reference ID),
these object IDs can be obtained via Managed Object Browser which is located on
the vCenter host, e.g. https://<vcenter_host>/mob

Starting from Fuel 9.0 settings on web UI are not disabled and it is possible
to run deployment process with changed settings against working cluster.  This
change also impacts plugin settings which means that plugin settings can be
changed and applied to Neutron. From plugin perspective it is not possible to
disable specific input fields, below settings that break Neutron operations are
commented.

Plugin contains the following settings:

#. NSX Manager hostname (or IP) -- if you are going to use hostname in this
   textbox be sure that your OpenStack controller will be able to resolve it.
   Add necessary DNS servers in *Host OS DNS Servers* section.  NSX Manager
   must be connected to vCenter server which you specified on VMware tab.

   OpenStack Controller must have L3 connectivity with NSX Manager through
   Public network.

#. NSX Manager username.

   .. note::

      In order for Neutron NSX plugin to operate properly account that it uses
      must have Enterprise administrator role.

#. NSX Manager password.

#. Bypass NSX Manager certificate verification -- if enabled then HTTPS
   connection will not be verified. Otherwise two options are available:

   * setting "CA certificate file" appear below making it possible to upload CA
     certificate that issued NSX Manager certificate.

   * no CA certificate provided, then NSX Manager certificate will be verified
     against CA certificate bundle that comes by default within OpenStack
     controller node operating system.

#. CA certificate file -- file in PEM format that contains bundle of CA
   certificates which will be used by the plugin during NSX Manager certificate
   verification. If no file is present, then HTTPS connection will not be
   verified.

#. Datacenter MoRef ID -- ID of Datacenter where NSX Edge nodes will be
   deployed.

#. Resource pool MoRef ID -- resource pool for NSX Edge nodes deployment.
   Setting change on deployed cluster affects only new Edges.

#. Datastore MoRef ID -- datastore for NSX Edge nodes. Change of datastore
   setting on deployed cluster affects only new Edges.

#. External portgroup MoRef ID -- portgroup through which NSX Edge nodes get
   connectivity with physical network.

#. Transport zone MoRef ID -- transport zone for VXLAN logical networks.

   .. note::

      This ID can be fetched using NSX Manager API
      https://<nsx_manager_host>/api/2.0/vdn/scopes

#. Distributed virtual switch MoRef ID -- ID of vSwitch connected to Edge
   cluster.

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
   Setting change on deployed cluster affects only new Edges.

#. Init metadata infrastructure -- If enabled, instance will attempt to
   initialize the metadata infrastructure to access to metadata proxy  service,
   otherwise metadata proxy will not be deployed.

#. Bypass metadata service certificate verification -- If enabled connection
   metadata service will be listening HTTP port. Otherwise self-signed
   certificate will be generated, installed into edge nodes and
   nova-api-metadata, HTTPS will be enabled.

#. Which network will be used to access the nova-metadata -- select network
   through which nova-api-metadata service will be available for NSX edge
   nodes. Currently two options are available *Public* and *Management*
   networks.

   If *Management* network selected, then free IP address from management
   network range for nova-api-metadata will be allocated automatically and
   you don't need to specify your own IP address, netmask, gateway.

   If *Public* network selected, then you need to specify you own IP address, netmask
   and gateway. See metadata related settings below.

   .. warning::

      Do not change metadata settings after cluster is deployed!

   To enable Nova metadata service, the following settings must be set:

#. Metadata allowed ports -- comma separated list of TCP port allowed access to
   the metadata proxy, in addition to 80, 443 and 8775.

#. Metadata portgroup MoRef ID -- portgroup MoRef ID for metadata proxy service.

#. Metadata proxy IP addresses -- comma separated IP addresses used by Nova
   metadata proxy service.

#. Management network netmask -- management network netmask for metadata proxy
   service.

#. Management network default gateway -- management network gateway for
   metadata proxy service.

#. Floating IP ranges -- dash separated IP addresses allocation pool from
   external network, e.g. "192.168.30.1-192.168.30.200".

#. External network CIDR -- network in CIDR notation that includes floating IP ranges.

#. Gateway -- default gateway for external network, if not defined, first IP address
   of the network is used.

#. Internal network CIDR -- network in CIDR notation for use as internal.

#. DNS for internal network -- comma separated IP addresses of DNS server for
   internal network.

   If you tick *Additional settings* checkbox following options will become
   available for configuration:

#. Instance name servers -- comma separated IP addresses of name servers that
   will be passed to instance.

#. Task status check interval -- asynchronous task status check interval,
   default is 2000 (millisecond).

#. Maximum tunnels per vnic -- specify maximum amount of tunnels per vnic,
   possible range of values 1-110 (20 is used if no other value is provided).

#. API retries -- maximum number of API retries (10 by default).

#. Enable SpoofGuard -- option allows to control behaviour of port-security
   feature that prevents traffic flow if IP address of VM that was reported by
   VMware Tools does not match source IP address that is observed in outgoing
   VM traffic (consider the case when VM was compromised).

#. Tenant router types -- ordered list of preferred tenant router types (default
   value is ``shared, distributed, exclusive``).

   * shared -- multiple shared routers may own one edge VM.
   * exclusive -- each router own one edge VM.
   * distributed -- same as exclusive, but edge is created as distributed
     logical router.  VM traffic get routed via DLR kernel modules on each
     ESXi host.

#. Exclusive router size -- size of edge for exclusive router
   (value must be one of *compact*, *large*, *quadlarge* or *xlarge*).

#. Edge user -- user that will be created on edge VMs for remote login.

#. Edge password -- password for edge VMs.  It must match following rules:

   * not less 12 characters (max 255 chars)
   * at least 1 upper case letter
   * at least 1 lower case letter
   * at least 1 number
   * at least 1 special character

   .. warning::

      Plugin cannot verify that password conforms security policy. If you enter
      password that does not match policy, Neutron server will be not able to
      create routers and deployment process will stop, because NSX will not
      permit creating edge nodes with password that does not match security
      policy.

#. DHCP lease time -- DHCP lease time in seconds for VMs. Default value is
   86400 (24 hours).

#. Coordinator URL -- URL for distributed locking coordinator.
