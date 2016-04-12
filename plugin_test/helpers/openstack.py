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

from fuelweb_test import logger
from fuelweb_test.helpers.common import Common
from fuelweb_test import settings as fw_settings

from helpers.tools import show_pos


class HopenStack(object):

    """
        HOpenStack - Helpers for OpenStack
    """

    def __init__(self, nsxv_ip):
        self._common = Common(controller_ip=nsxv_ip,
                              user=fw_settings.SERVTEST_USERNAME,
                              password=fw_settings.SERVTEST_PASSWORD,
                              tenant=fw_settings.SERVTEST_TENANT)

    @show_pos
    def create_network(self, name):
        """Create network.

        :param name: name of network
        """
        request_body = {'network': {"name": name}}
        network = self._common.neutron.create_network(body=request_body)

        network_id = network['network']['id']
        logger.debug("Created network id '{0}'".format(network_id))

        return network['network']

    @show_pos
    def create_subnetwork(self, network, cidr):
        """Create a subnet.

        :param network: dictionary
        :param cidr: string CIDR
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

    @show_pos
    def aggregate_create(self, name, availability_zone):
        """Create a aggregate.

        :param name: aggregate name
        :param availability_zone: availability zone name
        """
        return self._common.nova.aggregates.create(name, availability_zone)

    @show_pos
    def aggregate_host_remove(self, aggregate, hostname):
        """Remove host from aggregate

        :param aggregate: aggregate ID
        :param hostname: host name
        """
        return self._common.nova.aggregates.remove_host(aggregate, hostname)

    @show_pos
    def aggregate_host_add(self, aggregate, hostname):
        """Add host to aggregate
        :param aggregate: destination aggregate ID
        :param hostname: host name
        :return:
        """
        return self._common.nova.aggregates.add_host(aggregate, hostname)

    @show_pos
    def aggregate_list(self):
        """ Retrieve aggregates list
        :return: Aggregate objects list
        """
        return self._common.nova.aggregates.list()

    @show_pos
    def hosts_list(self, zone=None):
        """Retrieve hosts list
        :param zone: availability zone name, optional parameter
        :return: Host objects list
        """
        return self._common.nova.hosts.list(zone=zone)

    @show_pos
    def hosts_change_aggregate(self, agg_src, agg_dst, hostname):
        """Move host from one aggregate to another
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
