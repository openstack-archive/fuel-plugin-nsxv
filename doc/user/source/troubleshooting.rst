Troubleshooting
===============

Neutron NSX plugin issues
-------------------------

Neutron NSX plugin does not have separate log file it writes it is logged by
neutron server.  Default log file on OpenStack controllers for neutron server
is ``/var/log/neutron/server.log``

Inability to resolve NSX Manager hostname
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see following message::

 2016-02-19 07:40:00.124 17562 ERROR neutron.service [-] Unrecoverable error: please check log for details.
 2016-02-19 07:40:00.124 17562 ERROR neutron.service Traceback (most recent call last):
 ...
 2016-02-19 07:40:00.144 17562 ERROR neutron ServerNotFoundError: Unable to find the server at nsxmanager.mydom.org
 2016-02-19 07:40:00.144 17562 ERROR neutron

It means that controller cannot resolve NSX Manager hostname
(nsxmanager.mydom.org in this example) that is specified in config file. Check
that DNS server IP addresses are correct that you specified in *Host OS DNS
Servers* section of Fuel web UI are correct and reachable by all controllers
(pay attention that default route for controllers is *Public* network). If all
this is correct then verify that host name that you entered is correct try to
resolve it via ``host`` or ``dig`` programs.

SSL/TLS certificate problems
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 2016-02-19 09:03:23.648 10939 ERROR neutron   File "/usr/lib/python2.7/dist-packages/httplib2/__init__.py", line 1251, in _conn_request
        2016-02-19 09:03:23.648 10939 ERROR neutron     conn.connect()
 2016-02-19 09:03:23.648 10939 ERROR neutron   File "/usr/lib/python2.7/dist-packages/httplib2/__init__.py", line 1043, in connect
 2016-02-19 09:03:23.648 10939 ERROR neutron     raise SSLHandshakeError(e)
 2016-02-19 09:03:23.648 10939 ERROR neutron SSLHandshakeError: [Errno 1]_ssl.c:510: error:
        14090086:SSL routines:SSL3_GET_SERVER_CERTIFICATE:certificate verify failed

This error indicates that you enabled SSL/TLS certificate verification, but
certificate verification failed during connection to NSX Manager.  Possible
reasons of this:

 #. NSX Manager certificate expired. Log into NSX Manager web GUI and check
    certificate validation dates.
 #. Check certification authority (CA) certificate is still valid. CA
    certificate is specified by ``ca_file`` directive in ``nsx.ini``.


User access problems
~~~~~~~~~~~~~~~~~~~~

::

 2016-02-19 09:15:50.927 20382 CRITICAL neutron [-] Forbidden: Forbidden: https://172.16.0.249/api/1.0/appliance-management/summary/system
 ...
 2016-02-19 09:15:50.927 20382 ERROR neutron   File "/usr/lib/python2.7/dist-packages/vmware_nsx/plugins/nsx_v/vshield/common/VcnsApiClient.py", line 119, in request
 2016-02-19 09:15:50.927 20382 ERROR neutron     raise cls(uri=uri, status=status, header=header, response=response)
 2016-02-19 09:15:50.927 20382 ERROR neutron Forbidden: Forbidden: https://172.16.0.249/api/1.0/appliance-management/summary/system


Possible solutions:

 * Username is incorrect.
 * Password is incorrect.
 * User account does not have sufficient privileges to perform certain
   operations.

Non-existent vCenter entity specified
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If some settings of vCenter does not exist plugin will report following message
with varying setting that is not found in vCenter:

::

 2016-02-19 13:42:51.094 22001 ERROR neutron   File "/usr/lib/python2.7/dist-packages/vmware_nsx/plugins/nsx_v/plugin.py", line 2084, in _validate_config
 2016-02-19 13:42:51.094 22001 ERROR neutron     raise nsx_exc.NsxPluginException(err_msg=error)
 2016-02-19 13:42:51.094 22001 ERROR neutron NsxPluginException: An unexpected error occurred in the NSX Plugin: Configured datacenter_moid not found
 2016-02-19 13:42:51.094 22001 ERROR neutron

Non-existent transport zone
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If transport zone does not exist plugin will fail with following message:

::

 2016-02-19 09:20:27.065 3823 CRITICAL neutron [req-81bbb7f6-59ed-447c-8cac-6d651cf07351 - - - - -] NsxPluginException: An unexpected error occurred in the NSX Plugin: Configured vdn_scope_id not found
 ...
 2016-02-19 09:20:27.065 3823 ERROR neutron Traceback (most recent call last):
 2016-02-19 09:20:27.065 3823 ERROR neutron     raise nsx_exc.NsxPluginException(err_msg=error)
 2016-02-19 09:20:27.065 3823 ERROR neutron NsxPluginException: An unexpected error occurred in the NSX Plugin: Configured vdn_scope_id not found

You can get list of available transport zones via GET request to NSX Manager
API URL https://nsx-manager.yourdomain.org/api/2.0/vdn/scopes


NSX platform issues
-------------------

Transport network connectivity
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before debugging problems of VM connectivity when they get spread across
ESXi cluster hosts it is good to verify that transport (underlay) network
functions properly.

You can get list of vmknic adapters that are used for VXLAN tunnels with
``esxcli`` command by providing DVS name. Then use one as output interface for
ping and try to reach another ESXi host.

.. code-block:: bash

  ~# esxcli network vswitch dvs vmware vxlan vmknic list --vds-name computeDVS
  Vmknic Name  Switch Port ID  VDS Port ID  Endpoint ID  VLAN ID  IP           Netmask        IP Acquire Timeout  Multicast Group Count  Segment ID
  -----------  --------------  -----------  -----------  -------  -----------  -------------  ------------------  ---------------------  ----------
  vmk1               50331670  33                     0        0  172.16.0.91  255.255.255.0                   0                      0  172.16.0.0

Provide ``++netstack=vxlan`` option to operate via VXLAN networking stack.

.. code-block:: bash

  ~# ping ++netstack=vxlan -d -s 1550 -I vmk1 172.29.46.12

If host does not get respond try following options:

  * remove options ``-d`` (disable dont fragment bit) and ``-s`` (packet size)
    and try to ping. In this case ping will use 56 byte packets and if reply
    gets successfully delivered, consider revising MTU on network switches.
  * if ping with smaller packets also fails, consider uplink interface
    configuration (e.g. VLAN ID).


Verify NSX controllers state
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSX controllers must form cluster majority

You can verify NSX controllers cluster state in web UI (``Network & Security ->
Installation -> Management``). All of them must be in normal status.
