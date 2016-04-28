"""Copyright 2016 Mirantis, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.
"""
import os
import time

from devops.error import TimeoutError
from devops.helpers.helpers import wait

from fuelweb_test import logger

from fuelweb_test.helpers import os_actions
from fuelweb_test.helpers import utils

from fuelweb_test.helpers.common import Common

from fuelweb_test.helpers.decorators import log_snapshot_after_test

from fuelweb_test.settings import DEPLOYMENT_MODE
from fuelweb_test.settings import NEUTRON_SEGMENT_TYPE
from fuelweb_test.settings import SERVTEST_PASSWORD
from fuelweb_test.settings import SERVTEST_TENANT
from fuelweb_test.settings import SERVTEST_USERNAME

from fuelweb_test.tests.base_test_case import SetupEnvironment
from fuelweb_test.tests.base_test_case import TestBasic

from helpers import settings as pt_settings  # Plugin Tests Settings

from helpers.openstack import HopenStack

import paramiko

from proboscis import test

from proboscis.asserts import assert_false
from proboscis.asserts import assert_true


@test(groups=["plugins", "nsxv_plugin"])
class TestNSXvPlugin(TestBasic):
    """Here are automated tests from test plan that has mark 'Automated'."""

    _common = None
    plugin_name = 'nsxv'
    plugin_version = '3.0.0'

    net1 = {'name': 'net_1', 'cidr': '192.168.112.0/24'}
    net2 = {'name': 'net_2', 'cidr': '192.168.113.0/24'}

    def node_name(self, name_node):
        """Return name of node."""
        return self.fuel_web.get_nailgun_node_by_name(name_node)['hostname']

    def get_settings(self):
        """Return 'cluster_settings' dictionary."""
        cluster_settings = {'net_provider': 'neutron',
                            'assign_to_all_nodes': False,
                            'net_segment_type': NEUTRON_SEGMENT_TYPE}
        return cluster_settings

    def install_nsxv_plugin(self):
        """Install plugin on fuel node."""
        utils.upload_tarball(
            ip=self.ssh_manager.admin_ip,
            tar_path=pt_settings.NSXV_PLUGIN_PATH,
            tar_target='/var')

        utils.install_plugin_check_code(
            ip=self.ssh_manager.admin_ip,
            plugin=os.path.basename(pt_settings.NSXV_PLUGIN_PATH))

    def enable_plugin(self, cluster_id, settings={}):
        """Fill the necessary fields with required values.

        :param cluster_id: cluster id to use with Common
        :param settings: dict that will be merged with default settings
        """
        assert_true(
            self.fuel_web.check_plugin_exists(cluster_id, self.plugin_name),
            "Test aborted")

        # Enable metadata initializer
        pt_settings.plugin_configuration.update(
            {'nsxv_metadata_initializer/value': True})

        # Enable additional settings
        if settings:
            self.fuel_web.update_plugin_settings(cluster_id,
                                                 self.plugin_name,
                                                 self.plugin_version,
                                                 {'nsxv_additional/value':
                                                  True})
        # Update plugin settings
        self.fuel_web.update_plugin_settings(
            cluster_id,
            self.plugin_name,
            self.plugin_version,
            dict(pt_settings.plugin_configuration, **settings))

    def patch_haproxy(self, controllers):
        """To avoid 504 error we need to patch haproxy config.

        :param controllers: list of controller nodes
        """
        change_neutron_client_config = "sed -i 's/timeout  client-fin.*/" \
                                       "timeout  client-fin 600s/' " \
                                       "/etc/haproxy/conf.d/*neutron.cfg"
        change_neutron_server_config = "sed -i 's/timeout  server-fin.*/" \
                                       "timeout  server-fin 600s/' " \
                                       "/etc/haproxy/conf.d/*neutron.cfg"
        stop_haproxy = "service haproxy stop"
        start_haproxy = "service haproxy start"
        for controller in controllers:
            with self.fuel_web.get_ssh_for_node(controller) as remote:
                remote.execute(change_neutron_client_config)
                remote.execute(change_neutron_server_config)
                try:
                    wait(
                        lambda: remote.execute(stop_haproxy)['exit_code'] == 0,
                        timeout=60)
                except TimeoutError:
                    raise TimeoutError("Haproxy does not stop during 1 minute")

                try:
                    wait(
                        lambda: remote.execute(start_haproxy)[
                            'exit_code'] == 0,
                        timeout=60)
                except TimeoutError:
                    raise TimeoutError(
                        "Haproxy does not start during 1 minute")

    def create_instances(self, os_conn=None, vm_count=1, nics=None,
                         security_group=None, key_name=None,
                         availability_zone=None):
        """Create Vms on available hypervisors.

        :param os_conn: type object, openstack
        :param vm_count: type interger, count of VMs to create
        :param nics: type dictionary, neutron networks
                         to assign to instance
        :param security_group: type dictionary, security group to assign to
                            instances
        :param key_name: name of access key
        :param availability_zone:  type string, instance AZ
        """
        # Get list of available images,flavors and hipervisors
        images_list = os_conn.nova.images.list()
        flavors_list = os_conn.nova.flavors.list()

        for image in images_list:
            if image.name == 'TestVM-VMDK':
                os_conn.nova.servers.create(
                    flavor=flavors_list[0],
                    name='test_{0}'.format(image.name),
                    image=image,
                    min_count=vm_count,
                    availability_zone=availability_zone or 'vcenter',
                    key_name=key_name,
                    nics=nics)

        # Verify that current state of each VMs is Active
        srv_list = os_conn.get_servers()
        for srv in srv_list:
            assert_true(os_conn.get_instance_detail(srv).status != 'ERROR',
                        "Current state of Vm {0} is {1}".format(
                            srv.name, os_conn.get_instance_detail(srv).status))
            try:
                wait(
                    lambda:
                    os_conn.get_instance_detail(srv).status == "ACTIVE",
                    timeout=500)
            except TimeoutError:
                logger.error(
                    "Timeout is reached.Current state of Vm {0} is {1}".format(
                        srv.name, os_conn.get_instance_detail(srv).status))
            # assign security group
            if security_group:
                srv.add_security_group(security_group)

    def check_connection_vms(self, os_conn, srv_list, remote=None,
                             command='pingv4', result_of_command=0,
                             destination_ip=None):
        """Check network connectivity between instances and destination ip.

        :param os_conn: type object, openstack
        :param srv_list: type list, instances
        :param remote: SSHClient to primary controller
        :param command: could be pingv4(default), "pingv6", "arping"
        :param result_of_command: code result of command execution
        :param destination_ip: type list, remote destination ip to
                               check by ping
        """
        commands = {
            "pingv4": "ping -c 5 {}",
            "pingv6": "ping6 -c 5 {}",
            "arping": "sudo arping -I eth0 {}"}

        if not remote:
            primary_controller = self.fuel_web.get_nailgun_primary_node(
                self.env.d_env.nodes().slaves[0])

            remote = self.fuel_web.get_ssh_for_node(
                primary_controller.name)

        for srv in srv_list:
            addresses = srv.addresses[srv.addresses.keys()[0]]
            fip = [
                add['addr'] for add in addresses
                if add['OS-EXT-IPS:type'] == 'floating'][0]

            if not destination_ip:
                destination_ip = [s.networks[s.networks.keys()[0]][0]
                                  for s in srv_list if s != srv]

            for ip in destination_ip:
                if ip != srv.networks[srv.networks.keys()[0]][0]:
                    logger.info("Connect to VM {0}".format(fip))
                    command_result = os_conn.execute_through_host(
                        remote, fip,
                        commands[command].format(ip))
                    logger.info("Command result: \n"
                                "{stdout}\n"
                                "{stderr}\n"
                                "exit_code={exit_code}"
                                .format(stdout=command_result['stdout'],
                                        stderr=command_result['stderr'],
                                        exit_code=command_result['exit_code']))
                    assert_true(
                        result_of_command == command_result['exit_code'],
                        " Command {0} from Vm {1},"
                        " executed with code {2}".format(
                            commands[command].format(ip),
                            fip, command_result))

    def check_service(self, ssh=None, commands=None):
        """Check that required nova services are running on controller.

        There is a timeout for each of command 'WAIT_FOR_COMMAND'
        :param ssh: SSHClient
        :param commands: type list, nova commands to execute on controller,
                         example of commands:
                         ['nova-manage service list | grep vcenter-vmcluster1']
        """
        ssh.execute('source openrc')
        for cmd in commands:
            output = list(ssh.execute(cmd)['stdout'])
            wait(
                lambda:
                ':-)' in output[-1].split(' '),
                timeout=pt_settings.WAIT_FOR_COMMAND)

    def create_and_assign_floating_ip(self, os_conn=None, srv_list=None,
                                      ext_net=None, tenant_id=None):
        """Create and assign floating IPs for instances.

        :param os_conn: connection object
        :param srv_list: type list, instances
        :param ext_net: external network object
        :param tenant_id: id for current tenant. Admin tenant is by default.
        """
        fips = []
        if not ext_net:
            ext_net = [net for net
                       in os_conn.neutron.list_networks()["networks"]
                       if net['name'] == pt_settings.ADMIN_NET][0]
        if not tenant_id:
            tenant_id = os_conn.get_tenant(SERVTEST_TENANT).id
        if not srv_list:
            srv_list = os_conn.get_servers()
        for srv in srv_list:
            fip = os_conn.neutron.create_floatingip(
                {'floatingip': {
                    'floating_network_id': ext_net['id'],
                    'tenant_id': tenant_id}})
            fips.append(fip['floatingip']['floating_ip_address'])
            os_conn.nova.servers.add_floating_ip(
                srv, fip['floatingip']['floating_ip_address'])
        return fips

    def get_ssh_connection(self, ip, username, userpassword,
                           timeout=30, port=22):
        """Get ssh to host.

        :param ip: string, host ip to connect to
        :param username: string, a username to use for authentication
        :param userpassword: string, a password to use for authentication
        :param timeout: timeout (in seconds) for the TCP connection
        :param port: host port to connect to
        """
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            ip, port=port, username=username,
            password=userpassword, timeout=timeout
        )
        return ssh

    def remote_execute_command(self, instance1_ip, instance2_ip, command):
        """Check execute remote command.

        :param instance1: string, instance ip connect from
        :param instance2: string, instance ip connect to
        :param command: string, remote command
        """
        logger.info("Logged: {}  {}  {}".format(
            instance1_ip, instance2_ip, command))
        ssh = self.get_ssh_connection(instance1_ip, pt_settings.VM_USER,
                                      pt_settings.VM_PASS, timeout=30)

        interm_transp = ssh.get_transport()
        logger.info("Opening channel to VM")
        interm_chan = interm_transp.open_channel('direct-tcpip',
                                                 (instance2_ip, 22),
                                                 (instance1_ip, 0))
        logger.info("Opening paramiko transport")
        transport = paramiko.Transport(interm_chan)
        logger.info("Starting client")
        transport.start_client()
        logger.info("Passing authentication to VM")
        transport.auth_password(pt_settings.VM_USER, pt_settings.VM_PASS)
        channel = transport.open_session()
        channel.get_pty()
        channel.fileno()
        channel.exec_command(command)

        result = {
            'stdout': [],
            'stderr': [],
            'exit_code': 0
        }

        logger.debug("Receiving exit_code")
        result['exit_code'] = channel.recv_exit_status()
        logger.debug("Receiving stdout")
        result['stdout'] = channel.recv(1024)
        logger.debug("Receiving stderr")
        result['stderr'] = channel.recv_stderr(1024)

        logger.debug("Closing channel")
        channel.close()
        return result

    def get_common(self, cluster_id):
        """Return 'common' object.

        :param cluster_id: cluster id to use with Common
        """
        nsxv_ip = self.fuel_web.get_public_vip(cluster_id)
        self._common = Common(
            controller_ip=nsxv_ip, user=SERVTEST_USERNAME,
            password=SERVTEST_PASSWORD, tenant=SERVTEST_TENANT)
        return self._common

    def create_network(self, name, cluster_id=None):
        """Create network.

        :param name: name of network
        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        net_body = {"network": {"name": name}}
        network = common.neutron.create_network(net_body)['network']
        return network

    def delete_network(self, name, cluster_id=None):
        """Remove network.

        :param name: name of network
        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        common.neutron.delete_network(name)

    def create_net_public(self, cluster_id=None):
        """Create custom exteral net and subnet.

        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        network = common.neutron.create_network(body={
            'network': {
                'name': pt_settings.ADMIN_NET,
                'admin_state_up': True,
                'router:external': True,
                'shared': True, }})

        network_id = network['network']['id']
        logger.debug("id {0} to master node".format(network_id))

        common.neutron.create_subnet(body={
            'subnet': {
                'network_id': network_id,
                'ip_version': 4,
                'cidr': '172.16.0.0/24',
                'name': 'subnet04_ext',
                'allocation_pools': [{"start": "172.16.0.30",
                                      "end": "172.16.0.40"}],
                'gateway_ip': '172.16.0.1',
                'enable_dhcp': False, }})
        return network['network']

    def add_router(self, router_name, ext_net, distributed=False,
                   router_type='shared', cluster_id=None):
        """Create a router.

        :param router_name: name of router
        :param ext_net: external network object
        :param distributed: boolean
        :param router_type: shared or exclusive
        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        gateway = {"network_id": ext_net['id'],
                   "enable_snat": True}
        if distributed:
            router_param = {'router': {'name': router_name,
                                       'admin_state_up': True,
                                       'distributed': distributed,
                                       'external_gateway_info': gateway}}
        else:
            router_param = {'router': {'name': router_name,
                                       'admin_state_up': True,
                                       'router_type': router_type,
                                       'distributed': distributed,
                                       'external_gateway_info': gateway}}
        router = common.neutron.create_router(body=router_param)['router']
        return router

    def add_subnet_to_router(self, router_id, sub_id, cluster_id=None):
        """Attach subnet to router.

        :param router_id: router id
        :param sub_id: subnet id
        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        common.neutron.add_interface_router(
            router_id,
            {'subnet_id': sub_id})

    def create_subnet(self, network, cidr, cluster_id=None):
        """Create a subnet.

        :param network: dictionary
        :param cidr: string CIDR
        :param cluster_id: cluster id to use with Common
        """
        if not cluster_id:
            cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        subnet_body = {"subnet": {"network_id": network['id'],
                                  "ip_version": 4,
                                  "cidr": cidr,
                                  "name": 'subnet_{}'.format(
                                      network['name']),
                                  }
                       }
        subnet = common.neutron.create_subnet(subnet_body)['subnet']
        return subnet

    def create_all_necessary_stuff(self):
        """Create all that is required to launch smoke OSTF."""
        private_net = self.create_network(pt_settings.PRIVATE_NET)
        subnet_private = self.create_subnet(private_net, '10.100.0.0/24')
        public_net = self.create_net_public()
        router = self.add_router(pt_settings.DEFAULT_ROUTER_NAME, public_net)
        self.add_subnet_to_router(router['id'], subnet_private['id'])

    @test(depends_on=[SetupEnvironment.prepare_slaves_1],
          groups=["nsxv_smoke", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_smoke(self):
        """Deploy a cluster with NSXv Plugin.

        Scenario:
            1. Upload the plugin to master node
            2. Create cluster and configure NSXv for that cluster
            3. Provision one controller node
            4. Deploy cluster with plugin

        Duration 90 min

        """
        self.env.revert_snapshot('ready_with_1_slaves', skip_timesync=True)

        self.install_nsxv_plugin()

        # Configure cluster
        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign roles to nodes
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'], })

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id)

        self.enable_plugin(cluster_id=cluster_id)

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id,
            test_sets=['smoke'])

    def get_configured_clusters(self, node):
        """Get configured vcenter clusters moref id on controller.

        :param node: type string, devops node name with controller role
        """
        ssh = self.fuel_web.get_ssh_for_node(node)
        cmd = r"sed -rn 's/^\s*cluster_moid\s*=\s*([^ ]+)\s*$/\1/p' " \
              "/etc/neutron/plugin.ini"
        clusters_id = ssh.execute(cmd)['stdout']
        return (clusters_id[-1]).rstrip().split(',')

    @test(depends_on=[SetupEnvironment.prepare_slaves_5],
          groups=["nsxv_smoke_add_compute", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_smoke_add_compute(self):
        """Deploy a cluster with NSXv Plugin, after add compute-vmware role.

        Scenario:
            1. Upload the plugin to master node
            2. Create cluster and configure NSXv for that cluster
            3. Provision three controller node
            4. Deploy cluster with plugin
            5. Get configured clusters morefid from neutron config
            6. Add compute-vmware role
            7. Redeploy cluster with new node
            8. Get new configured clusters modrefid from neutron config
            9. Check new cluster added in neutron config

        Duration 90 min

        """
        self.env.revert_snapshot('ready_with_5_slaves', skip_timesync=True)

        self.install_nsxv_plugin()

        # Configure cluster
        settings = self.get_settings()
        settings["images_vcenter"] = True
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id, vc_glance=True)

        self.enable_plugin(cluster_id=cluster_id)

        controllers = ['slave-01', 'slave-02', 'slave-03']

        # Assign roles to nodes
        for node in controllers:
            self.fuel_web.update_nodes(cluster_id, {node: ['controller'], })

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        old_configured_clusters = {}
        for node in controllers:
            old_configured_clusters[node] = self.get_configured_clusters(node)
            logger.info("Old configured clusters on {0} is {1}"
                        .format(node, old_configured_clusters[node]))

        # Add 1 node with compute-vmware role and redeploy cluster
        self.fuel_web.update_nodes(
            cluster_id, {'slave-04': ['compute-vmware'], })

        target_node_2 = self.node_name('slave-04')

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        vc_glance=True,
                                        multiclusters=True,
                                        target_node_2=target_node_2)

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        new_configured_clusters = {}
        for node in controllers:
            new_configured_clusters[node] = self.get_configured_clusters(node)
            logger.info("New configured clusters on {0} is {1}"
                        .format(node, new_configured_clusters[node]))

        for node in controllers:
            assert_true(set(new_configured_clusters[node]) -
                        set(old_configured_clusters[node]),
                        "Clusters on node {0} not reconfigured".format(node))

    @test(depends_on=[SetupEnvironment.prepare_slaves_9],
          groups=["nsxv_bvt", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_bvt(self):
        """Deploy cluster with plugin and vmware datastore backend.

        Scenario:
            1. Upload plugins to the master node.
            2. Install plugin.
            3. Create cluster with vcenter.
            4. Add 3 node with controller role, compute-vmware, cinder-vmware.
            5. Deploy cluster.
            6. Run OSTF.

        Duration 3 hours

        """
        self.env.revert_snapshot("ready_with_9_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        settings = self.get_settings()
        settings["images_ceph"] = True
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign role to nodes
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'],
             'slave-02': ['controller'],
             'slave-03': ['controller'],
             'slave-04': ['ceph-osd'],
             'slave-05': ['ceph-osd'],
             'slave-06': ['ceph-osd'],
             'slave-07': ['compute-vmware'],
             'slave-08': ['cinder-vmware'], })

        target_node_1 = self.node_name('slave-07')

        # Configure VMware vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id,
            test_sets=['smoke', 'sanity', 'ha'],)

    @test(depends_on=[SetupEnvironment.prepare_slaves_9],
          groups=["nsxv_add_delete_nodes", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_add_delete_nodes(self):
        """Deploy cluster with plugin and vmware datastore backend.

        Scenario:
            1. Upload plugins to the master node.
            2. Install plugin.
            3. Create cluster with vcenter.
            4. Add 3 node with controller role, compute-vmware, cinder-vmware.
            5. Remove node cinder-vmware.
            6. Add node with cinder role.
            7. Redeploy cluster.
            8. Run OSTF.

        Duration 3 hours

        """
        self.env.revert_snapshot("ready_with_9_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign role to node
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'],
             'slave-02': ['controller'],
             'slave-03': ['controller'],
             'slave-04': ['compute-vmware'], })

        target_node_1 = self.node_name('slave-04')

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)
        self.fuel_web.verify_network(cluster_id)
        self.fuel_web.deploy_cluster_wait(
            cluster_id, timeout=pt_settings.WAIT_FOR_LONG_DEPLOY)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke'])

        # Add 1 node with cinder-vmware role and redeploy cluster
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-05': ['cinder-vmware'], })

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke'])

        # Remove node with cinder-vmware role
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-05': ['cinder-vmware'], }, False, True)

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke'])

    @test(depends_on=[SetupEnvironment.prepare_slaves_9],
          groups=["nsxv_add_delete_controller", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_add_delete_controller(self):
        """Deploy cluster with plugin, adding and deletion controler node.

        Scenario:
            1. Upload plugins to the master node.
            2. Install plugin.
            3. Create cluster with vcenter.
            4. Add 4 node with controller role.
            5. Add 1 node with cinder-vmware role.
            6. Add 1 node with compute role.
            7. Deploy cluster.
            8. Run OSTF.
            9. Remove node with controller role.
            10. Redeploy cluster.
            11. Run OSTF.
            12. Add node with controller role.
            13. Redeploy cluster.
            14. Run OSTF.

        Duration 3.5 hours

        """
        self.env.revert_snapshot("ready_with_9_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign role to node
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'],
             'slave-02': ['controller'],
             'slave-03': ['controller'],
             'slave-04': ['controller'],
             'slave-05': ['cinder-vmware'],
             'slave-06': ['compute-vmware'], })

        target_node_1 = self.node_name('slave-06')

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)
        self.fuel_web.verify_network(cluster_id)
        self.fuel_web.deploy_cluster_wait(
            cluster_id, timeout=pt_settings.WAIT_FOR_LONG_DEPLOY)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke', 'sanity'])

        common = self.get_common(cluster_id)
        common.create_key('add_delete_c')
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        ext = os_conn.get_network(pt_settings.ADMIN_NET)
        private_net = os_conn.get_network(pt_settings.PRIVATE_NET)
        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=2,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name='add_delete_c')
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        srv_list = os_conn.get_servers()
        assert_true(len(srv_list) == 2,
                    "Check that there are sufficient resources to create VMs")
        self.check_connection_vms(os_conn, srv_list)

        # Remove node with controller role
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-04': ['controller'], }, False, True)

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke', 'sanity', 'ha'],
            should_fail=1,
            failed_test_name=['Check that required services are running'])

        srv_list = os_conn.get_servers()
        assert_true(len(srv_list) == 2,
                    "Check that there are sufficient resources to create VMs")
        self.check_connection_vms(os_conn, srv_list)

        # Add node with controller role
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-04': ['controller'], })

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke', 'sanity', 'ha'],
            should_fail=1,
            failed_test_name=['Check that required services are running'])

        srv_list = os_conn.get_servers()
        assert_true(len(srv_list) == 2,
                    "Check that there are sufficient resources to create VMs")
        self.check_connection_vms(os_conn, srv_list)

    @test(depends_on=[SetupEnvironment.prepare_slaves_5],
          groups=["nsxv_ceilometer", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_ceilometer(self):
        """Deploy cluster with plugin and ceilometer.

        Scenario:
            1. Upload plugins to the master node.
            2. Install plugin.
            3. Create cluster with vcenter.
            4. Add 3 node with controller + mongo roles.
            5. Add 2 node with compute role.
            5. Deploy the cluster.
            6. Run OSTF.

        Duration 3 hours

        """
        self.env.revert_snapshot("ready_with_5_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        settings = self.get_settings()
        settings["ceilometer"] = True
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign role to node
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller', 'mongo'],
             'slave-02': ['controller', 'mongo'],
             'slave-03': ['controller', 'mongo'],
             'slave-04': ['compute-vmware']
             })

        target_node_1 = self.node_name('slave-04')

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)
        self.fuel_web.verify_network(cluster_id)
        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id,
            test_sets=['smoke', 'tests_platform'],)

    @test(depends_on=[SetupEnvironment.prepare_slaves_5],
          groups=["nsxv_ha_mode", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_ha_mode(self):
        """Deploy cluster with plugin in HA mode.

        Scenario:
            1. Upload plugins to the master node
            2. Install plugin.
            3. Create cluster with vcenter.
            4. Add 3 node with controller role.
            5. Add 2 node with compute role.
            6. Deploy the cluster.
            7. Run OSTF.

        Duration 2.5 hours

        """
        self.env.revert_snapshot("ready_with_5_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign role to node
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'],
             'slave-02': ['controller'],
             'slave-03': ['controller'],
             'slave-04': ['compute-vmware'], })

        target_node_1 = self.node_name('slave-04')

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)
        self.fuel_web.verify_network(cluster_id)
        self.fuel_web.deploy_cluster_wait(
            cluster_id,
            timeout=pt_settings.WAIT_FOR_LONG_DEPLOY)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke', 'sanity', 'ha'])

        # Create Availability zone and move host from one to another
        nsxv_ip = self.fuel_web.get_public_vip(cluster_id)
        hos = HopenStack(nsxv_ip)

        hos.aggregate_create('vcenter02', pt_settings.AZ_VCENTER2)
        hos.hosts_change_aggregate('vcenter',
                                   'vcenter02',
                                   'vcenter-vmcluster2')

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_floating_ip_to_public", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_floating_ip_to_public(self):
        """Check connectivity Vms to public network with floating ip.

        Scenario:
            1. Setup nsxv_ha_mode.
            2. Create net01: net01_subnet, 192.168.112.0/24 and
               attach it to the router04
            3. Launch instance VM_1 of vcenter1 AZ with image TestVM-VMDK and
               flavor m1.tiny in the net_04. Associate floating ip.
            4. Launch instance VM_1 of vcenter2 AZ with image TestVM-VMDK and
               flavor m1.tiny in the net_01. Associate floating ip.
            5. Send ping from instances VM_1 and VM_2 to 8.8.8.8 or
               other foreign ip.

        Duration 2,5 hours
        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        # Create os_conn
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(os_ip,
                                              SERVTEST_USERNAME,
                                              SERVTEST_PASSWORD,
                                              SERVTEST_TENANT)

        nsxv_ip = self.fuel_web.get_public_vip(cluster_id)
        hos = HopenStack(nsxv_ip)

        # Create  nets, subnet and attach them to the router
        net = os_conn.get_network(pt_settings.ADMIN_NET)

        router = self.os_conn.get_router_by_name(
            pt_settings.DEFAULT_ROUTER_NAME)

        private_net_1 = hos.create_network(self.net1['name'])
        private_net_2 = os_conn.get_network(pt_settings.PRIVATE_NET)

        subnet_private_1 = hos.create_subnetwork(
            private_net_1, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private_1['id'])

        sec_group = os_conn.create_sec_group_for_ssh()

        # Create instances in different Availability zones
        self.create_instances(os_conn=os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net_1['id']}],
                              security_group=sec_group.name,
                              availability_zone=pt_settings.AZ_VCENTER2)

        self.create_instances(os_conn=os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net_2['id']}],
                              security_group=sec_group.name,
                              availability_zone=pt_settings.AZ_VCENTER1)

        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=net)

        # Send ping from instances VM_1 and VM_2 to 8.8.8.8
        srv_list = os_conn.get_servers()
        self.check_connection_vms(os_conn,
                                  srv_list,
                                  destination_ip=[pt_settings.EXT_IP])

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_public_network_availability", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_public_network_availability(self):
        """Verify that public network is available.

        Scenario:
            1. Setup nsxv_ha_mode.
            2. Create net01: net01_subnet, 192.168.112.0/24 and
               attach it to default router.
            3. Launch instance VM_1 of vcenter1 AZ with image TestVM-VMDK and
               flavor m1.tiny in the default private net.
            4. Launch instance VM_1 of vcenter2 AZ with image TestVM-VMDK and
               flavor m1.tiny in the net_01.
            5. Send ping from instances VM_1 and VM_2
               to 8.8.8.8 or other outside ip.

        Duration 2,5 hours

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        # Create os_conn
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(os_ip,
                                              SERVTEST_USERNAME,
                                              SERVTEST_PASSWORD,
                                              SERVTEST_TENANT)

        nsxv_ip = self.fuel_web.get_public_vip(cluster_id)
        hos = HopenStack(nsxv_ip)

        # Create  nets, subnet and attach them to the router
        net = os_conn.get_network(pt_settings.PRIVATE_NET)
        router = self.add_router("shared", net)
        private_net_1 = hos.create_network(self.net1['name'])
        private_net_2 = hos.create_network(self.net2['name'])
        subnet_private_1 = hos.create_subnetwork(private_net_1,
                                                 self.net1['cidr'])
        subnet_private_2 = hos.create_subnetwork(private_net_2,
                                                 self.net2['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private_1['id'])
        self.add_subnet_to_router(router['id'], subnet_private_2['id'])

        sec_group = os_conn.create_sec_group_for_ssh()

        # Create instances in different Availability zones
        self.create_instances(os_conn=os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net_1['id']}],
                              security_group=sec_group.name,
                              availability_zone=pt_settings.AZ_VCENTER2)

        self.create_instances(os_conn=os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net_2['id']}],
                              security_group=sec_group.name,
                              availability_zone=pt_settings.AZ_VCENTER1)

        # Send ping from instances VM_1 and VM_2 to 8.8.8.8
        srv_list = os_conn.get_servers()
        self.check_connection_vms(os_conn,
                                  srv_list,
                                  destination_ip=[pt_settings.EXT_IP])

    @test(depends_on=[nsxv_smoke],
          groups=["nsxv_create_and_delete_vms", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_create_and_delete_vms(self):
        """Check creation instance in the one group simultaneously.

        Scenario:
            1. Revert snapshot to nsxv_smoke
            2. Upload plugins to the master node
            3. Install plugin.
            4. Create cluster with vcenter.
            5. Deploy the cluster.
            6. Create 5 instances of vcenter simultaneously.

        Duration 40 minutes

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        private_net = os_conn.get_network(pt_settings.PRIVATE_NET)

        # Create 5 instances of vcenter simultaneously
        self.create_instances(os_conn, vm_count=5, nics=[{'net-id':
                                                          private_net['id']}])
        srv_list = os_conn.get_servers()
        for server in srv_list:
            server.delete()

        wait(lambda: os_conn.get_servers() is None, timeout=300)

    @test(depends_on=[nsxv_smoke],
          groups=["nsxv_uninstall", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_uninstall(self):
        """Verify that uninstall of Fuel NSXv plugin is successful.

        Scenario:
            1. Revert snapshot to nsxv_deploy.
            2. Delete environment.
            3. Try to uninstall plugin.

        Duration 1 hour

        """
        self.env.revert_snapshot("deploy_nsxv", skip_timesync=True)

        cluster_id = self.fuel_web.get_last_created_cluster()

        self.fuel_web.delete_env_wait(cluster_id)

        # Try to uninstall nsxv plugin
        cmd = 'fuel plugins --remove {}=={}'.format(
            self.plugin_name, self.plugin_version)
        self.env.d_env.get_admin_remote().execute(cmd)['exit_code'] == 0

        # Check that plugin is removed
        output = list(self.env.d_env.get_admin_remote().execute(
            'fuel plugins list')['stdout'])

        assert_false(
            self.plugin_name in output[-1].split(' '),
            "{} plugin has not been removed".format(self.plugin_name))

    @test(depends_on=[nsxv_smoke],
          groups=["nsxv_uninstall_negative", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_uninstall_negative(self):
        """Verify that uninstall of Fuel NSXv plugin is unsuccessful.

        Scenario:
            1. Revert snapshot to nsxv_deploy.
            2. Try to uninstall plugin.

        Duration 1 hour

        """
        self.env.revert_snapshot("deploy_nsxv", skip_timesync=True)

        # Try to uninstall plugin
        cmd = 'fuel plugins --remove {}=={}'.format(
            self.plugin_name, self.plugin_version)
        self.env.d_env.get_admin_remote().execute(cmd)['exit_code'] == 1

        # Check that plugin is not removed
        output = list(self.env.d_env.get_admin_remote().execute(
            'fuel plugins list')['stdout'])

        assert_true(
            self.plugin_name in output[-1].split(' '),
            "Plugin is removed {}".format(self.plugin_name))

    @test(depends_on=[SetupEnvironment.prepare_slaves_3],
          groups=["nsxv_install", 'nsxv_plugin'])
    @log_snapshot_after_test
    def nsxv_install(self):
        """Verify that installation of Fuel NSXv plugin is successful.

        Scenario:
            1. Install plugin.

        Duration 10 mins

        """
        self.env.revert_snapshot('ready_with_3_slaves', skip_timesync=True)

        self.install_nsxv_plugin()

        # Check that plugin has been installed
        output = list(self.env.d_env.get_admin_remote().execute(
            'fuel plugins list')['stdout'])

        assert_true(
            self.plugin_name in output[-1].split(' '),
            "{} plugin has not been installed".format(self.plugin_name))

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_connectivity_via_shared_router", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_connectivity_via_shared_router(self):
        """Test connectivity via shared router.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Create cluster and configure NSXv for that cluster
            3. Deploy cluster with plugin
            4. Create shared router, create internal network.
            5. Attach created network to router.
            6. Launch instance VM_1, VM_2 on created network
            7. Send ping from instances VM_1 and VM_2 to 8.8.8.8

        Duration 90 min

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        ext = os_conn.get_network(pt_settings.ADMIN_NET)

        common.create_key('tmp_key1')
        router = self.add_router("shared", ext)
        # Create non default network with subnet.
        logger.info('Create network {}'.format(self.net1))
        private_net = self.create_network(self.net1['name'])
        subnet_private = self.create_subnet(private_net, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private['id'])
        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn, vm_count=2, nics=[{'net-id':
                                                          private_net['id']}],
                              security_group=sec_grp.name, key_name='tmp_key1')
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        # Send ping from instances VM_1 and VM_2 to 8.8.8.8
        srv_list = os_conn.get_servers()
        self.check_connection_vms(
            os_conn, srv_list, destination_ip=[pt_settings.EXT_IP])

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_connectivity_via_distributed_router", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_connectivity_via_distributed_router(self):
        """Test connectivity via distributed router.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Create cluster and configure NSXv for that cluster
            3. Deploy cluster with plugin
            4. Create distributed router, create internal network.
            5. Attach created network to router.
            6. Launch instance VM_1, VM_2 on created network
            7. Send ping from instances VM_1 and VM_2 to 8.8.8.8

        Duration 90 min

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT
        )
        ext = os_conn.get_network(pt_settings.ADMIN_NET)

        common.create_key('tmp_key2')
        router = self.add_router("distributed", ext, distributed=True)

        # Create non default network with subnet.
        logger.info('Create network {}'.format(self.net1))
        private_net = self.create_network(self.net1['name'])
        subnet_private = self.create_subnet(private_net, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private['id'])
        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=2,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name='tmp_key2')
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        # Send ping from instances VM_1 and VM_2 to 8.8.8.8
        srv_list = os_conn.get_servers()
        self.check_connection_vms(
            os_conn, srv_list, destination_ip=[pt_settings.EXT_IP])

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_connectivity_via_exclusive_router", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_connectivity_via_exclusive_router(self):
        """Test connectivity via exclusive router.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Create cluster and configure NSXv for that cluster
            3. Deploy cluster with plugin
            4. Create exclusive router, create internal network.
            5. Attach created network to router.
            6. Launch instance VM_1, VM_2 on created network
            7. Send ping from instances VM_1 and VM_2 to 8.8.8.8

        Duration 90 min

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        ext = os_conn.get_network(pt_settings.ADMIN_NET)

        common.create_key('tmp_key3')
        router = self.add_router("exclusive", ext, router_type='exclusive')

        # Create non default network with subnet.
        logger.info('Create network {}'.format(self.net1))
        private_net = self.create_network(self.net1['name'])
        subnet_private = self.create_subnet(private_net, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private['id'])
        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=2,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name='tmp_key3')
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        # Send ping from instances VM_1 and VM_2 to 8.8.8.8
        srv_list = os_conn.get_servers()
        self.check_connection_vms(
            os_conn, srv_list, destination_ip=[pt_settings.EXT_IP])

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_create_terminate_networks", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_create_terminate_networks(self):
        """Test creating and deleting networks.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Create cluster and configure NSXv for that cluster
            3. Deploy cluster with plugin
            4. Create 2 private networks net_1, net_2
            5. Remove private network net_1
            6. Add private network net_1

        Duration 60 min

        """
        # Create private networks with subnets
        logger.info('Create network {}'.format(self.net1))
        private_net1 = self.create_network(self.net1['name'])
        self.create_subnet(private_net1, self.net1['cidr'])
        logger.info('Create network {}'.format(self.net2))
        private_net2 = self.create_network(self.net2['name'])
        self.create_subnet(private_net2, self.net2['cidr'])

        self.delete_network(private_net1['id'])

        logger.info('Create network again {}'.format(self.net1))
        private_net1 = self.create_network(self.net1['name'])
        self.create_subnet(private_net1, self.net1['cidr'])

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_public_network_to_all_nodes", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_public_network_to_all_nodes(self):
        """Test the feature "Assign public network to all nodes" works.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Connect through ssh to Controller node. Run 'ifconfig'
            3. Connect through ssh to compute-vmware node. Run 'ifconfig'.
            4. Deploy environment with Assign public network to all nodes.
            5. Connect through ssh to Controller node. Run 'ifconfig'.
            6. Connect through ssh to compute-vmware node. Run 'ifconfig'.

        Duration 60 min

        """
        cluster_id = self.fuel_web.get_last_created_cluster()
        check_interface = 'ifconfig | grep br-ex'
        controller = 'slave-01'
        compute_vmware = 'slave-04'

        with self.fuel_web.get_ssh_for_node(controller) as remote:
            res = remote.execute(check_interface)
            assert_true(res['exit_code'] == 0,
                        "br-ex was not found on node {}".format(controller))
        with self.fuel_web.get_ssh_for_node(compute_vmware) as remote:
            res = remote.execute(check_interface)
            assert_false(res['exit_code'] == 0,
                         "br-ex was found on node {}".format(compute_vmware))

        # Reset cluster, reconfigure, deploy
        self.fuel_web.stop_reset_env_wait(cluster_id)
        self.fuel_web.wait_nodes_get_online_state(
            self.env.d_env.nodes().slaves[:5],
            timeout=10 * 60)

        attributes = self.fuel_web.client.get_cluster_attributes(cluster_id)
        attributes['editable']['public_network_assignment'][
            'assign_to_all_nodes']['value'] = True

        self.fuel_web.client.update_cluster_attributes(cluster_id, attributes)

        self.fuel_web.deploy_cluster_wait(
            cluster_id, timeout=pt_settings.WAIT_FOR_LONG_DEPLOY)

        with self.fuel_web.get_ssh_for_node(controller) as remote:
            res = remote.execute(check_interface)
            assert_true(res['exit_code'] == 0,
                        "br-ex was not found on node {}".format(controller))
        with self.fuel_web.get_ssh_for_node(compute_vmware) as remote:
            res = remote.execute(check_interface)
            assert_true(res['exit_code'] == 0,
                        "br-ex wasn't found on node {}".format(compute_vmware))

    @test(depends_on=[SetupEnvironment.prepare_slaves_3],
          groups=["nsxv_kvm_deploy", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_kvm_deploy(self):
        """Test deploy with KVM.

        Scenario:
            1. Create cluster based on KVM.
            2. Add controller and compute-vmware nodes.
            3. Deploy environment.

        Duration 30 min

        """
        self.env.revert_snapshot("ready_with_3_slaves", skip_timesync=True)

        self.install_nsxv_plugin()

        # Configure cluster with vcenter
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=self.get_settings(),
            configure_ssl=False)

        # Change hypervisor type to KVM
        attributes = self.fuel_web.client.get_cluster_attributes(cluster_id)
        attributes['editable']['common']['libvirt_type']['value'] = "kvm"
        self.fuel_web.client.update_cluster_attributes(cluster_id, attributes)

        # Assign role to node
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'],
             'slave-02': ['compute-vmware'], })

        target_node_1 = self.node_name('slave-02')

        # Configure VMware vCenter settings
        self.fuel_web.vcenter_configure(cluster_id,
                                        multiclusters=True,
                                        target_node_1=target_node_1)

        self.enable_plugin(cluster_id=cluster_id)

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id, test_sets=['smoke'])

    @test(depends_on=[SetupEnvironment.prepare_slaves_1],
          groups=["nsxv_specified_router_type", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_specified_router_type(self):
        """Deploy a cluster with NSXv Plugin.

        Scenario:
            1. Upload the plugin to master node
            2. Create cluster and configure NSXv for that cluster
            3. Provision one controller node
            4. Deploy cluster with plugin

        Duration 90 min

        """
        self.env.revert_snapshot('ready_with_1_slaves', skip_timesync=True)

        self.install_nsxv_plugin()

        # Configure cluster
        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign roles to nodes
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'], })

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id)

        self.enable_plugin(
            cluster_id, {'nsxv_tenant_router_types/value': 'exclusive'})

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id,
            test_sets=['smoke'])

    @test(depends_on=[SetupEnvironment.prepare_slaves_1],
          groups=["nsxv_metadata_mgt_disabled", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_metadata_mgt_disabled(self):
        """Check that option nsxv_metadata_listen is public by default.

        Scenario:
            1. Upload the plugin to master node
            2. Create cluster and configure NSXv for that cluster
            3. Provision one controller node
            4. Deploy cluster with plugin
            5. Launch instance
            6. wget metadata server address from launched instance

        Duration 60 min

        """
        self.env.revert_snapshot('ready_with_1_slaves', skip_timesync=True)

        self.install_nsxv_plugin()

        # Configure cluster
        settings = self.get_settings()
        # Configure cluster
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            mode=DEPLOYMENT_MODE,
            settings=settings,
            configure_ssl=False)

        # Assign roles to nodes
        self.fuel_web.update_nodes(
            cluster_id,
            {'slave-01': ['controller'], })

        # Configure VMWare vCenter settings
        self.fuel_web.vcenter_configure(cluster_id)

        self.enable_plugin(cluster_id)

        plugin_data = self.fuel_web.get_plugin_data(
            cluster_id, self.plugin_name, self.plugin_version)
        assert_true(plugin_data['nsxv_metadata_listen']['value'] == "public",
                    "Check default value of nsxv_metadata_listen")
        assert_true(plugin_data['nsxv_mgt_reserve_ip']['value'] is False,
                    "Check default value of nsxv_mgt_reserve_ip")

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.fuel_web.run_ostf(
            cluster_id=cluster_id,
            test_sets=['smoke'])

        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        ext = os_conn.get_network(pt_settings.ADMIN_NET)
        router = os_conn.get_router_by_name(pt_settings.DEFAULT_ROUTER_NAME)

        common.create_key('mgmt_key')

        # Create non default network with subnet.
        logger.info('Create network {}'.format(self.net1))
        private_net = self.create_network(self.net1['name'])
        subnet_private = self.create_subnet(private_net, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet_private['id'])
        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name='mgmt_key')

        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)
        srv_list = os_conn.get_servers()

        # SSH to instance and wget metadata ip
        primary_controller = self.fuel_web.get_nailgun_primary_node(
            self.env.d_env.nodes().slaves[0])
        remote = self.fuel_web.get_ssh_for_node(
            primary_controller.name)

        for srv in srv_list:
            addresses = srv.addresses[srv.addresses.keys()[0]]
            fip = [
                add['addr'] for add in addresses
                if add['OS-EXT-IPS:type'] == 'floating'][0]

            cmd = "wget -O - {}".format(pt_settings.METADATA_IP)
            command_result = os_conn.execute_through_host(
                remote, fip, cmd)

            assert_true(
                command_result['exit_code'] == 0, "Wget exits with error!")
            assert_true(
                command_result['stdout'].split('\n')[-1] == 'latest',
                "Wget does not return 'latest' item in stdout")

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_create_and_delete_secgroups", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_create_and_delete_secgroups(self):
        """Verify security group feature.

        Scenario:
            1. Setup nsxv_ha_mode.
            3. Launch instance VM_1 in the tenant network net_1 with image
               TestVM-VMDK and flavor m1.tiny in the vcenter1 az.
            4. Launch instance VM_2 in the tenant net_2 with image
               TestVM-VMDK and flavor m1.tiny in the vcenter2 az.
            5. Create security groups SG_1 to allow ICMP traffic.
            6. Add Ingress rule for ICMP protocol to SG_1.
            7. Create security groups SG_2 to allow TCP traffic 22 port.
               Add Ingress rule for TCP protocol to SG_2.
            8. Attach SG_1 to VMs.
            9. Attach SG_2 to VMs.
            10. Check ping between VM_1 and VM_2 and vice verse.
            11. ssh from VM_1 to VM_2 and vice verse.
            12. Delete custom rules from SG_1 and SG_2.
            13. Check ping and ssh arent available from VM_1 to VM_2
                and vice versa.
            14. Add Ingress rule for SSH protocol to SG_2.
            15. Check ssh from VM_1 to VM_2 and vice verse.
            16. Add Ingress rule for ICMP protocol to SG_1.
            17. Check ping between VM_1 and VM_2 and vice verse.
            18. Delete security groups.
            19. Attach Vms to default security group.
            20. Check SSH from VM_1 to VM_2 and vice verse.
            21. Check ping between VM_1 and VM_2 and vice verse.

        Duration 90 min

        """
        key = 'sec_grp_key'

        # security group rules
        tcp = {
            "security_group_rule":
            {"direction": "ingress",
             "port_range_min": "22",
             "ethertype": "IPv4",
             "port_range_max": "22",
             "protocol": "TCP",
             "security_group_id": ""}}
        icmp = {
            "security_group_rule":
            {"direction": "ingress",
             "ethertype": "IPv4",
             "protocol": "icmp",
             "security_group_id": ""}}

        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT
        )
        ext = os_conn.get_network(pt_settings.ADMIN_NET)
        router = os_conn.get_router_by_name(pt_settings.DEFAULT_ROUTER_NAME)

        common.create_key(key)

        # Create private networks with subnets
        logger.info('Create network {}'.format(self.net1))
        private_net1 = self.create_network(self.net1['name'])
        subnet1 = self.create_subnet(private_net1, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet1['id'])
        logger.info('Create network {}'.format(self.net2))
        private_net2 = self.create_network(self.net2['name'])
        subnet2 = self.create_subnet(private_net2, self.net2['cidr'])
        self.add_subnet_to_router(router['id'], subnet2['id'])

        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net1['id']}],
                              availability_zone=pt_settings.AZ_VCENTER1,
                              key_name=key)
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net2['id']}],
                              availability_zone=pt_settings.AZ_VCENTER2,
                              key_name=key)

        floating_ip = self.create_and_assign_floating_ip(
            os_conn=os_conn, ext_net=ext)
        srv_list = os_conn.get_servers()

        sg1 = os_conn.nova.security_groups.create(
            "SG1", "d")

        icmp["security_group_rule"]["security_group_id"] = sg1.id
        os_conn.neutron.create_security_group_rule(icmp)

        sg2 = os_conn.nova.security_groups.create(
            "SG2", "d2")

        tcp["security_group_rule"]["security_group_id"] = sg2.id
        os_conn.neutron.create_security_group_rule(tcp)

        logger.info("""Attach SG_1 and SG2 to instances""")
        for srv in srv_list:
            srv.add_security_group(sg1.id)
            srv.add_security_group(sg2.id)

        controller = self.fuel_web.get_nailgun_primary_node(
            self.env.d_env.nodes().slaves[0])

        with self.fuel_web.get_ssh_for_node(controller.name) as ssh_contr:
            self.check_connection_vms(
                os_conn, srv_list, remote=ssh_contr)

            ip_pair = [(ip_1, ip_2)
                       for ip_1 in floating_ip
                       for ip_2 in floating_ip
                       if ip_1 != ip_2]

            for ips in ip_pair:
                self.remote_execute_command(ips[0], ips[1], ' ')

            sg_rules = os_conn.neutron.list_security_group_rules()[
                'security_group_rules']
            sg_rules = [
                sg_rule for sg_rule
                in os_conn.neutron.list_security_group_rules()[
                    'security_group_rules']
                if sg_rule['security_group_id'] in [sg1.id, sg2.id]]
            for rule in sg_rules:
                os_conn.neutron.delete_security_group_rule(rule['id'])

            for ip in floating_ip:
                try:
                    self.get_ssh_connection(
                        ip, self.instance_creds[0],
                        self.instance_creds[1])
                except Exception as e:
                    logger.info('{}'.format(e))

            tcp["security_group_rule"]["security_group_id"] = sg2.id
            os_conn.neutron.create_security_group_rule(tcp)
            tcp["security_group_rule"]["direction"] = "ingress"
            os_conn.neutron.create_security_group_rule(tcp)

            for ips in ip_pair:
                wait(
                    lambda: self.remote_execute_command(
                        ips[0], ips[1], ' '), timeout=30, interval=5)

            self.check_connection_vms(
                os_conn, srv_list, remote=ssh_contr,
                result_of_command=1)

            icmp["security_group_rule"]["security_group_id"] = sg1.id
            os_conn.neutron.create_security_group_rule(icmp)
            icmp["security_group_rule"]["direction"] = "ingress"
            os_conn.neutron.create_security_group_rule(icmp)

            time.sleep(pt_settings.HALF_MIN_WAIT)

            self.check_connection_vms(
                os_conn, srv_list, remote=ssh_contr)

            srv_list = os_conn.get_servers()
            for srv in srv_list:
                for sg in srv.security_groups:
                    srv.remove_security_group(sg['name'])

            for srv in srv_list:
                srv.add_security_group('default')

            time.sleep(pt_settings.HALF_MIN_WAIT)

            self.check_connection_vms(
                os_conn, srv_list, remote=ssh_contr)

            for ips in ip_pair:
                self.remote_execute_command(ips[0], ips[1], ' ')

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_multi_vnic", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_multi_vnic(self):
        """Check abilities to assign multiple vNICs to a single VM.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Add two private networks (net_1 and net_2)
            3. Add one subnet (net_1_subnet_1: 192.168.101.0/24,
               net_2_subnet_2, 192.168.102.0/24) to each network. One of
               subnets should have gateway and another should not.
            4. Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny
               in vcenter1 az. Check abilities to assign multiple vNIC net_1
               and net_2 to VM_1.
            5. Launch instance VM_2 with image TestVM-VMDK and flavor m1.tiny
               in vcenter2 az. Check abilities to assign multiple vNIC net_1
               and net_2 to VM_2.
            6. Send icmp ping from VM_1 to VM_2 and vice versa.

        Duration 1.5 hours

        """
        key = 'mvnic'
        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        common.create_key(key)

        ext = os_conn.get_network(pt_settings.ADMIN_NET)
        router = os_conn.get_router_by_name(pt_settings.DEFAULT_ROUTER_NAME)

        # Create private networks with subnets
        logger.info('Create network {}'.format(self.net1))
        private_net1 = self.create_network(self.net1['name'])
        subnet1 = self.create_subnet(private_net1, self.net1['cidr'])
        self.add_subnet_to_router(router['id'], subnet1['id'])
        logger.info('Create network {}'.format(self.net2))
        private_net2 = self.create_network(self.net2['name'])
        self.create_subnet(private_net2, self.net2['cidr'])

        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net1['id']},
                                    {'net-id': private_net2['id']}],
                              security_group=sec_grp.name,
                              availability_zone=pt_settings.AZ_VCENTER1,
                              key_name=key)
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net1['id']},
                                    {'net-id': private_net2['id']}],
                              security_group=sec_grp.name,
                              availability_zone=pt_settings.AZ_VCENTER2,
                              key_name=key)
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        srv_list = os_conn.get_servers()
        for srv in srv_list:
            addresses = srv.addresses.keys()
            assert_true(len(addresses) == 2,
                        "Check nics on instance {}.".format(srv.name))

        self.check_connection_vms(
            os_conn, srv_list)

    @test(depends_on=[nsxv_ha_mode],
          groups=["nsxv_ability_to_bind_port", "nsxv_plugin"])
    @log_snapshot_after_test
    def nsxv_ability_to_bind_port(self):
        """Verify that system could manipulate with port.

        Scenario:
            1. Setup nsxv_ha_mode
            2. Launch instance VM_1 with image TestVM-VMDK and flavor m1.tiny.
            3. Launch instance VM_2 with image TestVM-VMDK and flavor m1.tiny.
            4. Verify that VMs should communicate between each other.
               Send icmp ping from VM_1 to VM_2 and vice versa.
            5. Disable NSX-v_port of VM_1.
            6. Verify that VMs should communicate between each other.
               Send icmp ping from VM_2 to VM_1 and vice versa.
            7. Enable NSX-v_port of VM_1.
            8. Verify that VMs should communicate between each other.
               Send icmp ping from VM_1 to VM_2 and vice versa.

        Duration 90 min

        """
        key = 'bind_port'
        cluster_id = self.fuel_web.get_last_created_cluster()
        common = self.get_common(cluster_id)
        os_ip = self.fuel_web.get_public_vip(cluster_id)
        os_conn = os_actions.OpenStackActions(
            os_ip, SERVTEST_USERNAME,
            SERVTEST_PASSWORD,
            SERVTEST_TENANT)

        common.create_key(key)
        ext = os_conn.get_network(pt_settings.ADMIN_NET)
        private_net = os_conn.get_network(pt_settings.PRIVATE_NET)

        sec_grp = os_conn.create_sec_group_for_ssh()
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name=key)
        self.create_instances(os_conn,
                              vm_count=1,
                              nics=[{'net-id': private_net['id']}],
                              security_group=sec_grp.name,
                              key_name=key)
        self.create_and_assign_floating_ip(os_conn=os_conn, ext_net=ext)

        srv_list = os_conn.get_servers()
        self.check_connection_vms(
            os_conn, srv_list)

        # Disabling port on the first available vm
        port = os_conn.neutron.list_ports(
            device_id=srv_list[0].id)['ports'][0]
        os_conn.neutron.update_port(
            port['id'], {'port': {'admin_state_up': False}})
        time.sleep(pt_settings.HALF_MIN_WAIT)
        # Check connection. Now it is not affected. Such implementation from
        # neutron plugin.
        self.check_connection_vms(
            os_conn, srv_list, result_of_command=0)

        # Enabling port
        os_conn.neutron.update_port(
            port['id'], {'port': {'admin_state_up': True}})
        time.sleep(pt_settings.HALF_MIN_WAIT)
        self.check_connection_vms(os_conn, srv_list)
