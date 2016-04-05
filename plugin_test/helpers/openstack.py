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
import inspect

from fuelweb_test import logger
from fuelweb_test.helpers.common import Common


from fuelweb_test import settings as fw_settings
from helpers import settings as plugin_settings


class HopenStack(object):
    """
        HOpenStack - Helpers for OpenStack
    """
    def __init__(self, nsxv_ip):
        self._common = Common(controller_ip=nsxv_ip,
                              user=fw_settings.SERVTEST_USERNAME,
                              password=fw_settings.SERVTEST_PASSWORD,
                              tenant=fw_settings.SERVTEST_TENANT)

    @property
    def pos(self):
        return '[{}.{}]'.format(self.__class__.__name__,
                                inspect.stack()[1][3])

    def create_network(self, network_params={}):
        logger.debug('{pos} {params}'.format(pos=self.pos,
                                             params=network_params))

        request_body = {'network': network_params}
        network = self._common.neutron.create_network(body=request_body)

        network_id = network['network']['id']
        logger.debug("id {0} to master node".format(network_id))
        return network['network']

    def create_subnetwork(self, params={}):
        logger.debug('{pos} {params}'.format(pos=self.pos,
                                             params=params))
        subnet = self._common.neutron.create_subnet(body={'subnet': params})
        return subnet['subnet']
