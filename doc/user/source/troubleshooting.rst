
.. _troubleshooting:

Troubleshooting
===============

Neutron NSX plugin issues
-------------------------

The Neutron NSX plugin does not have a separate log file, its messages
are logged by the neutron server. The default log file on OpenStack controllers
for neutron server is ``/var/log/neutron/server.log``

Inability to resolve NSX Manager hostname
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see following message::

 2016-02-19 ... ERROR neutron.service [-] Unrecoverable error: please check log for details.
 2016-02-19 ... ERROR neutron.service Traceback (most recent call last):
 ...
 2016-02-19 ... ERROR neutron ServerNotFoundError: Unable to find the server at nsxmanager.mydom.org
 2016-02-19 ... ERROR neutron

It means that the controller cannot resolve the NSX Manager hostname
(``nsxmanager.mydom.org`` in this example) that is specified in the
configuration file.
Check that the DNS server IP addresses that you specified in the
:guilabel:`Host OS DNS Servers` section of the Fuel web UI are correct
and reachable by all controllers; pay attention to that the default route
for controllers is *Public* network. Also, verify that the host name that you
entered is correct by trying to resolve it via the ``host`` or ``dig`` programs.

SSL/TLS certificate problems
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 2016-02-19 ... ERROR neutron   File "/usr/lib/python2.7/dist-packages/httplib2/__init__.py",
    line 1251, in _conn_request
        2016...  10939 ERROR neutron     conn.connect()
 2016-02-19 ... ERROR neutron   File "/usr/lib/python2.7/dist-packages/httplib2/__init__.py",
    line 1043, in connect
 2016-02-19 ... ERROR neutron     raise SSLHandshakeError(e)
 2016-02-19 ... ERROR neutron SSLHandshakeError: [Errno 1]_ssl.c:510: error:
        14090086:SSL routines:SSL3_GET_SERVER_CERTIFICATE:certificate verify failed

This error indicates that you enabled the SSL/TLS certificate verification, but
the certificate verification failed during connection to NSX Manager.
The possible causes are:

 #. NSX Manager certificate expired. Log into NSX Manager web GUI and check
    certificate validation dates.
 #. Check if the certification authority (CA) certificate is still valid.
    The CA certificate is specified by ``ca_file`` directive in ``nsx.ini``.

User access problems
~~~~~~~~~~~~~~~~~~~~

::

 2016-02-19 ... CRITICAL neutron [-] Forbidden: Forbidden: https://172.16.0.249/api/1.0/
    appliance-management/summary/system
 ...
 2016-02-19 ... ERROR neutron   File "/usr/lib/python2.7/dist-packages/vmware_nsx/plugins/
    nsx_v/vshield/common/VcnsApiClient.py", line 119, in request
 2016-02-19 ... ERROR neutron     raise cls(uri=uri, status=status, header=header, response=response)
 2016-02-19 ... ERROR neutron Forbidden: Forbidden: https://172.16.0.249/api/1.0/
    appliance-management/summary/system

Possible solutions:

 * Username is incorrect.
 * Password is incorrect.
 * User account does not have sufficient privileges to perform certain
   operations.

Non-existent vCenter entity specified
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If some settings of vCenter do not exist, the plugin will report the following
message with varying settings is not found in vCenter:

::

 2016-02-19 ... ERROR neutron   File "/usr/lib/python2.7/dist-packages/vmware_nsx/plugins/
    nsx_v/plugin.py", line 2084, in _validate_config
 2016-02-19 ... ERROR neutron     raise nsx_exc.NsxPluginException(err_msg=error)
 2016-02-19 ... ERROR neutron NsxPluginException: An unexpected error occurred in the NSX
    Plugin: Configured datacenter_moid not found
 2016-02-19 ... ERROR neutron

Non-existent transport zone
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the transport zone does not exist, the plugin will fail with the following message:

::

 2016-02-19 ... CRITICAL neutron [req-81bbb7f6-...] NsxPluginException: An unexpected error
    occurred in the NSX Plugin: Configured vdn_scope_id not found
 ...
 2016-02-19 ... ERROR neutron Traceback (most recent call last):
 2016-02-19 ... ERROR neutron     raise nsx_exc.NsxPluginException(err_msg=error)
 2016-02-19 ... ERROR neutron NsxPluginException: An unexpected error occurred in the NSX
    Plugin: Configured vdn_scope_id not found

You can get the list of available transport zones via GET request to NSX Manager
API URL ``https://nsx-manager.yourdomain.org/api/2.0/vdn/scopes``

Neutron client returns 504 Gateway timeout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

 root@node-1:~# neutron router-create r_app --router_type exclusive
 Result:
 <html><body><h1>504 Gateway Time-out</h1>
 The server didn't respond in time.
 </body></html>

This may signal that your NSX Manager or vCenter server are overloaded and
cannot handle the incoming requests in a certain amount of time. A possible
solution to this problem is to increase the haproxy timeouts for nova API and neutron.
Double values of the following settings:

* timeout client
* timeout client-fin
* timeout server
* timeout server-fin

Edit the configuration files in ``/etc/haproxy/conf.d`` and restart
haproxy on all controllers.

NSX platform issues
-------------------

Transport network connectivity
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before debugging the problems of VM connectivity when they spread across
ESXi cluster hosts, verify that the transport (underlay) network
functions properly.

You can get the list of vmknic adapters used for VXLAN tunnels with the
``esxcli`` command by providing DVS name. Then use one as output interface for
ping and try to reach another ESXi host.

::

  ~ # esxcli network vswitch dvs vmware vxlan vmknic list --vds-name computeDVS
  Vmknic Name  Switch Port ID  VDS Port ID  Endpoint ID  VLAN ID  IP           Netmask
  -----------  --------------  -----------  -----------  -------  -----------  -------------
  vmk1               50331670  33                     0        0  172.16.0.91  255.255.255.0

Provide the ``++netstack=vxlan`` option to operate via VXLAN networking stack.

::

  ~ # ping ++netstack=vxlan -d -s 1550 -I vmk1 172.29.46.12

If the host does not respond, try following options:

  * remove the options ``-d`` (disable don't fragment bit) and ``-s`` (packet size)
    and try to ping. In this case the ping will use 56 byte packets and if a reply
    gets successfully delivered, consider revising MTU on the network switches.
  * if the ping with smaller packets also fails, consider uplink interface
    configuration (e.g. VLAN ID).

Verify NSX controllers state
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSX controllers must form cluster majority.

You can verify NSX controllers cluster state in the Fuel web UI at
:guilabel:`Network & Security` -> :guilabel:`Installation -> Management`.
All of them must be in normal status.

Verify ESXi hosts connectivity with NSX controllers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Check that each ESXi host established connection with NSX controllers:

::

 ~ # esxcli network ip  connection list | grep 1234
 tcp         0       0  172.16.0.252:51916              192.168.130.101:1234
 ESTABLISHED     77203  newreno  netcpa-worker

Check that all connections are in the ESTABLISHED state. If connection is not
established:

* Check that the ESXi host can reach NSX controller.
* Check that the firewall is between ESXi host and NSX controller.
* Check that netcp agent (process that is responsible for communication between
  ESXi and NSX controller) is running: ``/etc/init.d/netcpad status``. If it is
  not running, try starting it and check that it is running:

::

  ~ # /etc/init.d/netcpad start
  ~ # /etc/init.d/netcpad status
  netCP agent service is running

Verify that Control Plane is Enabled and the connection is up::

  ~ # esxcli network vswitch dvs vmware vxlan network list --vds-name computeDVS
  VXLAN ID  Multicast IP               Control Plane
        Controller Connection  Port Count  MAC Entry Count  ARP Entry Count
  --------  -------------------------  -----------------------------------
        ---------------------  ----------  ---------------  ---------------
  5000      N/A (headend replication)  Enabled (multicast proxy,ARP proxy)
        192.168.130.101 (up)            2                0                0

vSphere/NSX infrastructure is not running after power outage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vCenter and NSX management VMs must be started in a certain order.
Please see `VMware KB article
<https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2139067>`_.
