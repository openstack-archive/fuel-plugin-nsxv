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
from functools import wraps

from fuelweb_test import logger


def show_pos(f):
    """Wrapper shows current POSition in debug output"""
    @wraps(f)
    def wrapper(*args, **kwargs):
        logger.debug('Call {func}({argc}, {argv})'.format(f.__name__,
                                                          args,
                                                          kwargs))
        return f(*args, **kwargs)
    return wrapper

