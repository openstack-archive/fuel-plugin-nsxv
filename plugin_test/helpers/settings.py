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

from fuelweb_test.settings import get_var_as_bool


HALF_MIN_WAIT = 30  # 30 seconds
WAIT_FOR_COMMAND = 60 * 3  # 3 minutes
WAIT_FOR_LONG_DEPLOY = 60 * 180  # 180 minutes

EXT_IP = '8.8.8.8'  # Google DNS ^_^
PRIVATE_NET = "admin_internal_net"
ADMIN_NET = 'admin_floating_net'
DEFAULT_ROUTER_NAME = 'router04'
METADATA_IP = '169.254.169.254'
VM_USER = 'cirros'
VM_PASS = 'cubswin:)'
AZ_VCENTER1 = 'vcenter'
AZ_VCENTER2 = 'vcenter2'


NSXV_PLUGIN_PATH = os.environ.get('NSXV_PLUGIN_PATH')

plugin_configuration = {
    'nsxv_manager_host/value': os.environ.get('NSXV_MANAGER_IP'),
    'nsxv_insecure/value': get_var_as_bool(
        os.environ.get('NSXV_INSECURE'), True),
    'nsxv_user/value': os.environ.get('NSXV_USER'),
    'nsxv_password/value': os.environ.get('NSXV_PASSWORD'),
    'nsxv_datacenter_moid/value': os.environ.get('NSXV_DATACENTER_MOID'),
    'nsxv_resource_pool_id/value': os.environ.get('NSXV_RESOURCE_POOL_ID'),
    'nsxv_datastore_id/value': os.environ.get('NSXV_DATASTORE_ID'),
    'nsxv_external_network/value': os.environ.get('NSXV_EXTERNAL_NETWORK'),
    'nsxv_vdn_scope_id/value': os.environ.get('NSXV_VDN_SCOPE_ID'),
    'nsxv_dvs_id/value': os.environ.get('NSXV_DVS_ID'),
    'nsxv_backup_edge_pool/value': os.environ.get('NSXV_BACKUP_EDGE_POOL'),
    'nsxv_mgt_net_moid/value': os.environ.get('NSXV_MGT_NET_MOID'),
    'nsxv_mgt_net_proxy_ips/value': os.environ.get('NSXV_MGT_NET_PROXY_IPS'),
    'nsxv_mgt_net_proxy_netmask/value': os.environ.get(
        'NSXV_MGT_NET_PROXY_NETMASK'),
    'nsxv_mgt_net_default_gateway/value': os.environ.get(
        'NSXV_MGT_NET_DEFAULT_GW'),
    'nsxv_floating_ip_range/value': os.environ.get('NSXV_FLOATING_IP_RANGE'),
    'nsxv_floating_net_cidr/value': os.environ.get('NSXV_FLOATING_NET_CIDR'),
    'nsxv_internal_net_cidr/value': os.environ.get('NSXV_INTERNAL_NET_CIDR'),
    'nsxv_floating_net_gw/value': os.environ.get('NSXV_FLOATING_NET_GW'),
    'nsxv_internal_net_dns/value': os.environ.get('NSXV_INTERNAL_NET_DNS'),
    'nsxv_edge_ha/value': get_var_as_bool(
        os.environ.get('NSXV_EDGE_HA'), False),
}
