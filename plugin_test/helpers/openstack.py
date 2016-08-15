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

from keystoneclient.exceptions import Conflict
from keystoneclient.exceptions import NotFound

from fuelweb_test import logger
from fuelweb_test import settings as fw_settings

from fuelweb_test.helpers.common import Common

from helpers.tools import find_first
from helpers.tools import ShowPos


def get_openstack_list_paginator(page_size=10):
    """Retrieve information from openstack via pagination.

    NOTE: This decorator is not applicable for:
        * cinder.volume_snaphosts.list
        * glance.images.list
        * keystone.users.list
        * neutron.list_networks
        * neutron.list_subnets
        * neutron.list_routers
        * neutron.list_ports
    because 'limit' is not working or not implemented in their API methods.
    """
    assert callable(page_size) is False, 'This is not a decorator'
    assert type(page_size) is int, 'page_size is not Int'

    def paginator(fn):
        def under_page(*args, **kwargs):
            # Process listing as a regular call due to limit or
            # marker parameters were passed
            limit = kwargs.pop('limit', None)
            marker = kwargs.pop('marker', None)
            if limit or marker:
                res = fn(*args, limit=limit, marker=marker, **kwargs)
                for item in res:
                    yield item
                return
            # Process listing with a pagination
            last_item_id = None
            while True:
                items = fn(*args, limit=page_size,
                           marker=last_item_id, **kwargs)
                if not items:
                    break
                for item in items:
                    if type(item) is dict:
                        last_item_id = item['id']
                    else:
                        last_item_id = item.id
                    yield item

        def paged_requester(*args, **kwargs):
            return [item for item in under_page(*args, **kwargs)]

        # return under_page
        return paged_requester
    return paginator


class HopenStack(ShowPos):
    """HOpenStack - Helpers for OpenStack."""

    def __init__(self, nsxv_ip, user=None, password=None, tenant=None):
        """Init Common.

        :param nsxv_ip: controller ip
        """
        user = user or fw_settings.SERVTEST_USERNAME
        password = password or fw_settings.SERVTEST_PASSWORD
        tenant = tenant or fw_settings.SERVTEST_TENANT
        self._common = Common(controller_ip=nsxv_ip,
                              user=user,
                              password=password,
                              tenant=tenant)

    def create_network(self, name):
        """Create network.

        :param name: name of network
        :return: dict with network info
        """
        request_body = {'network': {"name": name}}
        network = self._common.neutron.create_network(body=request_body)

        network_id = network['network']['id']
        logger.debug("Created network id '{0}'".format(network_id))

        return network['network']

    def create_subnetwork(self, network, cidr):
        """Create a subnet.

        :param network: dictionary
        :param cidr: string CIDR
        :return: dict with subnet info
        """
        subnet_params = {
            "subnet": {"network_id": network['id'],
                       "ip_version": 4,
                       "cidr": cidr,
                       "name": 'subnet_{}'.format(
                           network['name']),
                       }
        }
        subnet = self._common.neutron.create_subnet(subnet_params)['subnet']
        logger.debug("Created sub network id '{0}'".format(subnet['id']))

        return subnet

    def aggregate_create(self, name, availability_zone):
        """Create a aggregate.

        :param name: aggregate name
        :param availability_zone: availability zone name
        :return: answer on create aggregation request
        """
        return self._common.nova.aggregates.create(name, availability_zone)

    def aggregate_host_remove(self, aggregate, hostname):
        """Remove host from aggregate.

        :param aggregate: aggregate ID
        :param hostname: host name
        :return: answer on remove_host request
        """
        return self._common.nova.aggregates.remove_host(aggregate, hostname)

    def aggregate_host_add(self, aggregate, hostname):
        """Add host to aggregate.

        :param aggregate: destination aggregate ID
        :param hostname: host name
        :return: answer on add_host request
        """
        return self._common.nova.aggregates.add_host(aggregate, hostname)

    def aggregate_list(self):
        """Retrieve aggregates list.

        :return: Aggregate objects list
        """
        return self._common.nova.aggregates.list()

    def hosts_list(self, zone=None):
        """Retrieve hosts list.

        :param zone: availability zone name, optional parameter
        :return: Host objects list
        """
        return self._common.nova.hosts.list(zone=zone)

    def hosts_change_aggregate(self, agg_src, agg_dst, hostname):
        """Move host from one aggregate to another.

        :param agg_src: Source aggregate ID
        :param agg_dst: Destination aggregate ID
        :param hostname: Host name
        """
        aggs = self.aggregate_list()
        agg_src_id = None
        agg_dst_id = None
        for agg in aggs:
            if agg.name == agg_src:
                agg_src_id = agg.id
            if agg.name == agg_dst:
                agg_dst_id = agg.id
        if agg_src_id is not None and agg_dst_id is not None:
            self.aggregate_host_remove(agg_src_id, hostname)
            self.aggregate_host_add(agg_dst_id, hostname)
        else:
            logger.error(
                "Aggregate not found. agg_src id:{0}, agg_dst id:{1}".format(
                    agg_src_id, agg_dst_id
                ))

    def role_get(self, role_name):
        """Get user role by name.

        :param role_name: string role name
        :return role: dict with role description
        """
        try:
            role = self._common.keystone.roles.find(name=role_name)
        except NotFound:
            return None
        return role

    def user_get(self, username):
        """Get user by user name.

        :param username: string user name
        :return role: dict with user description
        """
        user = find_first(self._common.keystone.users.list(),
                          lambda x: x.name == username)
        return user

    @get_openstack_list_paginator()  # use pagination with defalt page size
    def tenants_list(self, limit=None, marker=None):
        """List tenants.

        :param limit: how much tenants to be listed
        :param marker: from which position list the tenants
        :return tenants: list with tenants
        """
        tenants = self._common.keystone.tenants.list(limit=limit,
                                                     marker=marker)
        return tenants

    def tenants_create(self, tenant_name):
        """Create tenant with given name.

        :param tenant_name: name of tenant
        :return tenant: dict with tenant details
        """
        tenant = find_first(self.tenants_list(),
                            lambda x: x.name == tenant_name)
        if tenant is None:
            tenant = self._common.keystone.tenants.create(
                tenant_name=tenant_name,
                enabled=True)
            logger.info("Created tenant name:'{0}', id:'{1}'".format(
                tenant_name, tenant.id))
        else:
            logger.warning(
                "Tenant already exist, name: '{0}' id: '{1}'".format(
                    tenant_name, tenant.id))
        return tenant

    def tenant_assign_user_role(self, tenant, user, role):
        """Link tenant with user ad role.

        :param tenant: name of tenant
        :param user: name of user
        :param user: name of role
        :return res: dict keystone answer
        """
        res = self._common.keystone.roles.add_user_role(user, role, tenant)
        return res

    def security_group_create(self, name, description=''):
        """Create security group.

        :param name: name of security group
        :param description: string with description
        :return: security group object
        """
        return self._common.nova.security_groups.create(name, description)

    def security_group_add_rule(self, tenant_id, group):
        """Add rule to security group.

        :param tenant_id: tenant id
        :param group: security group object
        """
        body = {'security_group_rule': {'direction': 'ingress',
                                        'security_group_id': group.id,
                                        'tenant_id': tenant_id}
                }
        try:
            self._common.neutron.create_security_group_rule(body=body)
        except Conflict as e:
            logger.warning(
                "Can't create rule for tenant {0}. Exception: {1}".format(
                    tenant_id, e))
