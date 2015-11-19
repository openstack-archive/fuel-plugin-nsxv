#!/usr/bin/python
import atexit
import argparse
import ssl, sys
import requests
requests.packages.urllib3.disable_warnings()

from pyVim import connect
from pyVmomi import vmodl
from pyVmomi import vim


objects = {'datacenter': vim.Datacenter, 'cluster': vim.ClusterComputeResource,
           'pool': vim.ResourcePool, 'datastore': vim.Datastore,
           'portgroup': (vim.dvs.DistributedVirtualPortgroup, vim.Network),
           'switch': vim.dvs.VmwareDistributedVirtualSwitch}


def get_moid(service_instance, name, type):
    content = service_instance.RetrieveContent()
    object_view = content.viewManager.CreateContainerView(content.rootFolder, [], True)
    for obj in object_view.view:
        if isinstance(obj, objects[type]):
            if str(obj.name) == name:
                moid = obj._moId
                parent = []
                while obj.parent:
                    parent.append(obj.parent.name)
                    obj = obj.parent
                print '->'.join(reversed(parent)) + ': ' + moid

    object_view.Destroy()
    return


def get_args():
    parser = argparse.ArgumentParser(
        description='Standard Arguments for talking to vCenter')

    # because -h is reserved for 'help' we use -s for service
    parser.add_argument('-s', '--host',
                        required=True,
                        action='store',
                        help='vSphere service to connect to')

    # because we want -p for password, we use -o for port
    parser.add_argument('-o', '--port',
                        type=int,
                        default=443,
                        action='store',
                        help='Port to connect on')

    parser.add_argument('-u', '--user',
                        required=True,
                        action='store',
                        help='User name to use when connecting to host')

    parser.add_argument('-p', '--password',
                        required=True,
                        action='store',
                        help='Password to use when connecting to host')

    parser.add_argument('-n', '--name',
                        required=True,
                        action='store',
                        help='Object name')

    parser.add_argument('-t', '--type',
                        required=True,
                        action='store',
                        help='Object types: %s' %(', '.join(objects.keys())))

    args = parser.parse_args()
    return args


def main():
    args = get_args()

    try:
        # workaround https://github.com/vmware/pyvmomi/issues/235
        default_context = ssl._create_default_https_context
        ssl._create_default_https_context = ssl._create_unverified_context
        service_instance = connect.SmartConnect(host=args.host,
                                                user=args.user,
                                                pwd=args.password,
                                                port=int(args.port))
        ssl._create_default_https_context = default_context

        if not service_instance:
            print("Could not connect to the specified host using specified "
                  "username and password")
            return 1

        atexit.register(connect.Disconnect, service_instance)

        get_moid(service_instance,args.name,args.type)

    except vmodl.MethodFault, e:
        print "Caught vmodl fault : " + e.msg
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
