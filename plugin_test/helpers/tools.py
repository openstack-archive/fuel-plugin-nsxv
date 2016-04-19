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

from functools import wraps

from fuelweb_test import logger


def find_first(seq, predicate):
    """Find next item from sequence."""
    return next((x for x in seq if predicate(x)), None)


class ShowPos(object):
    """Print func name and it's parameters for each call."""

    @staticmethod
    def deco(f):
        """Logger decorator."""
        def wrapper(*args, **kwargs):
            logger.debug("Call {0}({1}, {2})".format(f.__name__, args, kwargs))
            return f(*args, **kwargs)
        return wrapper

    def __getattribute__(self, name):
        """Log by attributes."""
        attr = object.__getattribute__(self, name)
        if callable(attr):
            return ShowPos.deco(attr)
        else:
            return attr


def show_pos(f):
    """Wrapper shows current POSition in debug output."""
    @wraps(f)
    def wrapper(*args, **kwargs):
        logger.debug('Call {func}({args}, {kwargs})'.format(func=f.__name__,
                                                            args=args,
                                                            kwargs=kwargs))
        return f(*args, **kwargs)
    return wrapper
