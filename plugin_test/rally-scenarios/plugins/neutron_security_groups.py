# Copyright (c) 2015 Mirantis Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from rally.common.i18n import _
from rally import consts
from rally import exceptions
from rally.plugins.openstack import scenario
from rally.plugins.openstack.scenarios.neutron import utils as net_utils
from rally.plugins.openstack.scenarios.nova import utils as nova_utils
from rally.task import atomic
from rally.task import types
from rally.task import validation


class NeutronSecurityGroupException(exceptions.RallyException):
    msg_fmt = _("%(message)s")


class NeutronSecGroupPlugin(net_utils.NeutronScenario,
                            nova_utils.NovaScenario):
    """Benchmark scenarios for Neutron security groups."""

    def _neutron_create_security_groups(self, security_group_count):
        security_groups = []
        with atomic.ActionTimer(self, "neutron.create_%s_security_groups" %
                security_group_count):
            for i in range(security_group_count):
                sg_name = self.generate_random_name()
                sg = self.clients("neutron").create_security_group({
                    'security_group': {
                        'name': sg_name,
                        'description': 'Rally SG'}})['security_group']
                security_groups.append(sg)

        return security_groups

    def _neutron_delete_security_groups(self, security_group):
        with atomic.ActionTimer(self, "neutron.delete_%s_security_groups" % len(security_group)):
            [self.clients("neutron").delete_security_group(sg['id']) for sg in security_group]

    def _neutron_create_rules_for_security_group(
            self, security_groups, rules_per_security_group,
            ip_protocol="tcp", cidr="0.0.0.0/0"):
        action_name = ("neutron.create_%s_rules" % (
            rules_per_security_group * len(security_groups)))
        with atomic.ActionTimer(self, action_name):
            for i in range(len(security_groups)):
                for j in range(rules_per_security_group):
                    from_port = i * rules_per_security_group + j + 1
                    to_port = i * rules_per_security_group + j + 1

                    self.clients("neutron").create_security_group_rule({
                        'security_group_rule': {
                            'direction': 'ingress',
                            'remote_group_id': None,
                            'remote_ip_prefix': cidr,
                            'port_range_min': from_port,
                            'ethertype': 'IPv4',
                            'port_range_max': to_port,
                            'protocol': ip_protocol,
                            'security_group_id': security_groups[i]['id']
                        }})

    def _neutron_list_security_groups(self):
        """Return security groups list."""
        with atomic.ActionTimer(self, "neutron.list_security_groups"):
            return self.clients("neutron").list_security_groups()

    RESOURCE_NAME_PREFIX = "rally_neutronsecgrp_"

    @types.set(image=types.ImageResourceType,
               flavor=types.FlavorResourceType)
    @validation.image_valid_on_flavor("flavor", "image")
    @validation.required_parameters("security_group_count",
                                    "rules_per_security_group")
    @validation.required_contexts("network")
    @validation.required_services(consts.Service.NEUTRON, consts.Service.NOVA)
    @validation.required_openstack(users=True)
    @scenario.configure(context={"cleanup": ["nova", "neutron"]})
    def boot_server_with_secgroups(self, image, flavor,
                                   security_group_count,
                                   rules_per_security_group,
                                   **kwargs):
        """Boot and delete server with security groups attached.

        Plan of this scenario:
         - create N security groups with M rules per group
           vm with security groups)
         - boot a VM with created security groups
         - get list of attached security groups to server
         - check that all groups were attached to server

        :param image: ID of the image to be used for server creation
        :param flavor: ID of the flavor to be used for server creation
        :param security_group_count: Number of security groups
        :param rules_per_security_group: Number of rules per security group
        :param **kwargs: Optional arguments for booting the instance
        """

        security_groups = self._neutron_create_security_groups(
            security_group_count)
        self._neutron_create_rules_for_security_group(
            security_groups, rules_per_security_group)

        secgroups_names = [sg['name'] for sg in security_groups]
        server = self._boot_server(image, flavor,
                                   security_groups=secgroups_names,
                                   **kwargs)

        action_name = "neutron.get_attached_security_groups"
        with atomic.ActionTimer(self, action_name):
            attached_security_groups = server.list_security_group()

        if sorted([sg['id'] for sg in security_groups]) != sorted(
                [sg.id for sg in attached_security_groups]):
            raise NeutronSecurityGroupException(
                "Expected number of attached security groups to server "
                "%(server)s is '%(all)s', but actual number is '%(attached)s'."
                % {
                    "attached": len(attached_security_groups),
                    "all": len(security_groups),
                    "server": server})
