Configuration
=============

Switch to the :guilabel:`Networks` tab of the Fuel web UI and click the
:guilabel:`Settings`/`Other` section. The plugin checkbox is enabled
by default. The screenshot below shows only the settings in focus:

.. image:: /image/nsxv-settings-filled.png
   :scale: 60 %

Several plugin input fields refer to MoRef ID (Managed Object Reference ID);
these object IDs can be obtained using Managed Object Browser, which is located on
the vCenter host, e.g. https://<vcenter_host>/mob

Starting from Fuel 9.0, the settings on the Fuel web UI are not disabled
and it is possible to run the deployment process with the changed settings
against a working cluster.
This change also impacts the plugin settings as they can be changed and
applied to Neutron. From the plugin perspective, it is not possible to
disable specific input fields, the settings below that break Neutron
operations are commented.

The plugin contains the following settings:

#. NSX Manager hostname (or IP) -- if you are going to use hostname in this
   textbox, ensure that your OpenStack controller can resolve the hostname.
   Add necessary DNS servers in the :guilabel:`Host OS DNS Servers` section.
   NSX Manager must be connected to the vCenter server specified on
   the VMware tab.

   OpenStack Controller must have L3 connectivity with NSX Manager through
   the Public network.

#. NSX Manager username.

   .. note::

      For the Neutron NSX plugin to operate properly, the account in use
      must have an Enterprise administrator role.

#. NSX Manager password.

#. Bypass NSX Manager certificate verification -- if enabled, the HTTPS
   connection is not verified. Otherwise, the two following options are
   available:

   * The setting "CA certificate file" appears below making it possible to
     upload a CA certificate that issued the NSX Manager certificate.

   * With no CA certificate provided, the NSX Manager certificate is verified
     against the CA certificate bundle that comes by default within the
     OpenStack controller node operating system.

#. CA certificate file -- a file in PEM format that contains a bundle of CA
   certificates used by the plugin during the NSX Manager certificate
   verification. If no file is present, the HTTPS connection is not
   verified.

#. Datacenter MoRef ID -- an ID of the Datacenter where the NSX Edge nodes
   are deployed.

#. Resource pool MoRef ID -- a resource pool for the NSX Edge nodes deployment.
   Changing this setting on a deployed cluster affects only the new Edges.

#. Datastore MoRef ID -- a datastore for NSX Edge nodes. A change of the datastore
   setting on the deployed cluster affects only the new Edges.

#. External portgroup MoRef ID -- a portgroup through which the NSX Edge nodes get
   connectivity with the physical network.

#. Transport zone MoRef ID -- a transport zone for VXLAN logical networks.

   .. note::

      This ID can be fetched using NSX Manager API
      https://<nsx_manager_host>/api/2.0/vdn/scopes

#. Distributed virtual switch MoRef ID -- ID of vSwitch connected to the Edge
   cluster.

#. NSX backup Edge pool -- the size of the NSX Edge nodes and the size of Edge
   pool. The value must be in the format: <edge_type>:[edge_size]:<min_edges>:<max_edges>.

   **edge_type** can take the following values: *service* or *vdr* (service and
   distributed edge, respectively).

   NSX *service* nodes provide such services as DHCP, DNS, firewall, NAT, VPN,
   routing and load balancing.

   NSX *vdr* nodes performs distributed routing and bridging.

   **edge_size** can take the following values: *compact*, *large* (the default
   value if omitted), *xlarge*, *quadlarge*.

   **min_edges** and **max_edges** define the minimum and maximum amount of NSX
   Edge nodes in pool.

   The following table describes the NSX Edge types:

   ========= ===================
   Edge size Edge VM parameters
   ========= ===================
   compact   1 vCPU 512  MB vRAM
   large     2 vCPU 1024 MB vRAM
   quadlarge 4 vCPU 1024 MB vRAM
   xlarge    6 vCPU 8192 MB vRAM
   ========= ===================

   Example values:

   ``service:compact:1:2,vdr:compact:1:3``

   ``service:xlarge:2:6,service:large:4:10,vdr:large:2:4``

#. Enable HA for NSX Edges -- if you enable this option, the NSX Edges will be
   deployed in active/standby pair on different ESXi hosts.
   Changing this setting on a deployed cluster affects only the new Edges.

#. Init metadata infrastructure -- if enabled, the instance attempts to
   initialize the metadata infrastructure to access to metadata proxy service;
   otherwise, the metadata proxy is not deployed.

#. Bypass metadata service certificate verification -- if enabled, the connection
   metadata service listens the HTTP port. Otherwise, a self-signed
   certificate is generated, installed into the Edge nodes, and
   nova-api-metadata; HTTPS is enabled.

#. Which network will be used to access the nova-metadata -- select a network
   through which the nova-api-metadata service will be available for the
   NSX Edge nodes. Currently two options are available the *Public* and *Management*
   networks.

   If the *Management* network is selected, then the free IP address from the
   management network range for nova-api-metadata is allocated automatically;
   you do not need to specify your own IP address, netmask, gateway.

   If the *Public* network is selected, then you need to specify you own IP
   address, netmask, and gateway. See the metadata related settings below.

   .. warning::

      Do not change the metadata settings after the cluster is deployed.

   To enable the Nova metadata service, the following settings must be set:

#. Metadata allowed ports -- a comma-separated list of TCP ports allowed access
   to the metadata proxy in addition to 80, 443 and 8775.

#. Metadata portgroup MoRef ID -- a portgroup MoRef ID for the metadata proxy
   service.

#. Metadata proxy IP addresses -- comma-separated IP addresses used by Nova
   metadata proxy service.

#. Management network netmask -- management network netmask for the metadata
   proxy service.

#. Management network default gateway -- management network gateway for
   the metadata proxy service.

#. Floating IP ranges -- dash-separated IP addresses allocation pool from
   external network, e.g. "192.168.30.1-192.168.30.200".

#. External network CIDR -- network in CIDR notation that includes floating IP ranges.

#. Gateway -- default gateway for the external network; if not defined, the
   first IP address of the network is used.

#. Internal network CIDR -- network in CIDR notation for use as internal.

#. DNS for internal network -- comma-separated IP addresses of DNS server for
   internal network.

   If you tick the :guilabel:`Additional settings` checkbox, the following
   options will become available for configuration:

#. Instance name servers -- comma-separated IP addresses of the name servers
   that are passed to the instance.

#. Task status check interval -- asynchronous task status check interval,
   the default value is 2000 (millisecond).

#. Maximum tunnels per vnic -- specify the maximum amount of tunnels per vnic;
   the possible range of values is 1-110 (20 is used if no other value is
   provided).

#. API retries -- maximum number of API retries (10 by default).

#. Enable SpoofGuard -- the option allows to control the behaviour of
   the port-security feature that prevents traffic flow if the IP address
   of the VM that was reported by VMware Tools does not match the source IP
   address that is observed in outgoing VM traffic (consider the case when
   VM was compromised).

#. Tenant router types -- an ordered list of preferred tenant router types
   (the default value is ``shared, distributed, exclusive``).

   * shared -- multiple shared routers may own one edge VM.
   * exclusive -- each router owns one edge VM.
   * distributed -- same as exclusive, but edge is created as a distributed
     logical router. The VM traffic is routed via DLR kernel modules on each
     ESXi host.

#. Exclusive router size -- the size of edge for the exclusive router
   (the value must be one of *compact*, *large*, *quadlarge* or *xlarge*).

#. Edge user -- the user that will be created on edge VMs for remote login.

#. Edge password -- password for edge VMs. The password must match
   the following rules:

   * not less 12 characters (max 255 chars)
   * at least 1 upper case letter
   * at least 1 lower case letter
   * at least 1 number
   * at least 1 special character

   .. warning::

      The plugin cannot verify that password conforms to the security policy.
      If you enter the password that does not match the policy, Neutron server
      will be not able to create routers and the deployment process will stop,
      because NSX cannot permit creating edge nodes with a password that does
      not match the security policy.

#. DHCP lease time -- DHCP lease time in seconds for VMs. The default value is
   86400 (24 hours).

#. Coordinator URL -- URL for the distributed locking coordinator.
