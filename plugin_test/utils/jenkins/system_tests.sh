#!/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# functions

INVALIDOPTS_ERR=100
NOJOBNAME_ERR=101
NOISOPATH_ERR=102
NOWORKSPACE_ERR=104
NOISOFOUND_ERR=107

# Defaults

export REBOOT_TIMEOUT=${REBOOT_TIMEOUT:-5000}
export ALWAYS_CREATE_DIAGNOSTIC_SNAPSHOT=${ALWAYS_CREATE_DIAGNOSTIC_SNAPSHOT:-true}

ShowHelp() {
cat << EOF
System Tests Script

It can perform several actions depending on Jenkins JOB_NAME it's ran from
or it can take names from exported environment variables or command line options
if you do need to override them.

-w (dir)    - Path to workspace where fuelweb git repository was checked out.
              Uses Jenkins' WORKSPACE if not set
-e (name)   - Directly specify environment name used in tests
              Uses ENV_NAME variable is set.
-j (name)   - Name of this job. Determines ISO name, Task name and used by tests.
              Uses Jenkins' JOB_NAME if not set
-v          - Do not use virtual environment
-V (dir)    - Path to python virtual environment
-i (file)   - Full path to ISO file to build or use for tests.
              Made from iso dir and name if not set.
-o (str)    - Allows you any extra command line option to run test job if you
              want to use some parameters.
-a (str)    - Allows you to path NOSE_ATTR to the test job if you want
              to use some parameters.
-A (str)    - Allows you to path  NOSE_EVAL_ATTR if you want to enter attributes
              as python expressions.
-m (name)   - Use this mirror to build ISO from.
              Uses 'srt' if not set.
-b (num)    - Allows you to override Jenkins' build number if you need to.
-l (dir)    - Path to logs directory. Can be set by LOGS_DIR evironment variable.
              Uses WORKSPACE/logs if not set.
-k          - Keep previously created test environment before tests run
-K          - Keep test environment after tests are finished
-h          - Show this help page

Most variables uses guesses from Jenkins' job name but can be overriden
by exported variable before script is run or by one of command line options.

You can override following variables using export VARNAME="value" before running this script
WORKSPACE  - path to directory where Fuelweb repository was checked out by Jenkins or manually
JOB_NAME   - name of Jenkins job that determines which task should be done and ISO file name.

If task name is "iso" it will make iso file
Other defined names will run Nose tests using previously built ISO file.

ISO file name is taken from job name prefix
Task name is taken from job name suffix
Separator is one dot '.'

For example if JOB_NAME is:
mytest.somestring.iso
ISO name: mytest.iso
Task name: iso
If ran with such JOB_NAME iso file with name mytest.iso will be created

If JOB_NAME is:
mytest.somestring.node
ISO name: mytest.iso
Task name: node
If script was run with this JOB_NAME node tests will be using ISO file mytest.iso.

First you should run mytest.somestring.iso job to create mytest.iso.
Then you can ran mytest.somestring.node job to start tests using mytest.iso and other tests too.
EOF
}

GetoptsVariables() {
  while getopts ":w:j:i:t:o:a:A:m:U:r:b:V:l:dkKe:v:h" opt; do
    case $opt in
      w)
        WORKSPACE="${OPTARG}"
        ;;
      j)
        JOB_NAME="${OPTARG}"
        ;;
      i)
        ISO_PATH="${OPTARG}"
        ;;
      o)
        TEST_OPTIONS="${TEST_OPTIONS} ${OPTARG}"
        ;;
      a)
        NOSE_ATTR="${OPTARG}"
        ;;
      A)
        NOSE_EVAL_ATTR="${OPTARG}"
        ;;
      m)
        USE_MIRROR="${OPTARG}"
        ;;
      V)
        VENV_PATH="${OPTARG}"
        ;;
      l)
        LOGS_DIR="${OPTARG}"
        ;;
      k)
        KEEP_BEFORE="yes"
        ;;
      K)
        KEEP_AFTER="yes"
        ;;
      e)
        ENV_NAME="${OPTARG}"
        ;;
      v)
        VENV="no"
        ;;
      h)
        ShowHelp
        exit 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        ShowHelp
        exit $INVALIDOPTS_ERR
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        ShowHelp
        exit $INVALIDOPTS_ERR
        ;;
    esac
  done
}

CheckVariables() {

  USE_MIRROR="${USE_MIRROR:=bud}"
  VENV="${VENV:=yes}"

  if [ -z "${ISO_PATH}" ]; then
    echo "Error! ISO_PATH is not set!"
    exit $NOISOPATH_ERR
  fi
  if [ ! -f "${ISO_PATH}" ]; then
    echo "Error! ${ISO_PATH} not found!"
    exit $NOISOFOUND_ERR
  fi
  if [ -z "${JOB_NAME}" ]; then
    echo "Error! JOB_NAME is not set!"
    exit $NOJOBNAME_ERR
  fi
  if [ -z "${WORKSPACE}" ]; then
    echo "Error! WORKSPACE is not set!"
    exit $NOWORKSPACE_ERR
  fi

  if [ -z "${VCENTER_PASSWORD}" ]; then
    echo "Error! VCENTER_PASSWORD is not set!"
    exit 1
  fi
  if [ -z "${WORKSTATION_SNAPSHOT}" ]; then
    echo "Error! WORKSTATION_SNAPSHOT is not set!"
    exit 1
  fi
  if [ -z "${WORKSTATION_USERNAME}" ]; then
    echo "Error! WORKSTATION_USERNAME is not set!"
    exit 1
  fi
  if [ -z "${WORKSTATION_PASSWORD}" ]; then
    echo "Error! WORKSTATION_PASSWORD is not set!"
    exit 1
  fi

  if [ -z "${NSXV_PLUGIN_PATH}" ]; then
    echo "Error! NSXV_PLUGIN_PATH is not set!"
    exit 1
  fi
  if [ -z "${NSXV_PASSWORD}" ]; then
    echo "Error! NSXV_PASSWORD is not set!"
    exit 1
  fi

  [ -z "${VENV_PATH}" ] && \
    export VENV_PATH="/home/jenkins/venv-nailgun-tests"

  [ -z "${POOL_PUBLIC}" ] && \
    export POOL_PUBLIC='172.16.0.0/24:24'

  [ -z "${POOL_MANAGEMENT}" ] && \
    export POOL_MANAGEMENT='172.16.1.0/24:24'

  [ -z "${POOL_PRIVATE}" ] && \
    export POOL_PRIVATE='192.168.0.0/24:24'


  # vCenter variables
  [ -z "${DISABLE_SSL}" ] && \
    export DISABLE_SSL="true"

  [ -z "${VCENTER_USE}" ] && \
    export VCENTER_USE="true"

  [ -z "${VCENTER_IP}" ] && \
    export VCENTER_IP="172.16.0.254"

  [ -z "${VCENTER_USERNAME}" ] && \
    export VCENTER_USERNAME="administrator@vsphere.local"

  [ -z "${VC_DATACENTER}" ] && \
    export VC_DATACENTER="Datacenter"

  [ -z "${VC_DATASTORE}" ] && \
    export VC_DATASTORE="nfs"

  [ -z "${VCENTER_IMAGE_DIR}" ] && \
    export VCENTER_IMAGE_DIR="/openstack_glance"

  [ -z "${WORKSTATION_NODES}" ] && \
    export WORKSTATION_NODES="esxi1 esxi2 esxi3 vcenter trusty"

  [ -z "${WORKSTATION_IFS}" ] && \
    export WORKSTATION_IFS="vmnet1 vmnet5"

  [ -z "${VCENTER_CLUSTERS}" ] && \
    export VCENTER_CLUSTERS="Cluster1,Cluster2"

  # NSXv variables
  [ -z "${NEUTRON_SEGMENT_TYPE}" ] && \
    export NEUTRON_SEGMENT_TYPE="tun"

  [ -z "${NSXV_MANAGER_IP}" ] && \
    export NSXV_MANAGER_IP="172.16.0.249"

  [ -z "${NSXV_USER}" ] && \
    export NSXV_USER='administrator@vsphere.local'

  [ -z "${NSXV_DATACENTER_MOID}" ] && \
    export NSXV_DATACENTER_MOID='datacenter-126'

  [ -z "${NSXV_RESOURCE_POOL_ID}" ] && \
    export NSXV_RESOURCE_POOL_ID='resgroup-134'

  [ -z "${NSXV_DATASTORE_ID}" ] && \
    export NSXV_DATASTORE_ID='datastore-138'

  [ -z "${NSXV_EXTERNAL_NETWORK}" ] && \
    export NSXV_EXTERNAL_NETWORK='dvportgroup-319'

  [ -z "${NSXV_VDN_SCOPE_ID}" ] && \
    export NSXV_VDN_SCOPE_ID='vdnscope-1'

  [ -z "${NSXV_DVS_ID}" ] && \
    export NSXV_DVS_ID='dvs-309'

  [ -z "${NSXV_BACKUP_EDGE_POOL}" ] && \
    export NSXV_BACKUP_EDGE_POOL='service:compact:1:2,vdr:compact:1:2'

  [ -z "${NSXV_MGT_NET_MOID}" ] && \
    export NSXV_MGT_NET_MOID=${NSXV_EXTERNAL_NETWORK:?}

  [ -z "${NSXV_MGT_NET_PROXY_IPS}" ] && \
    export NSXV_MGT_NET_PROXY_IPS='172.16.212.99'

  [ -z "${NSXV_MGT_NET_PROXY_NETMASK}" ] && \
    export NSXV_MGT_NET_PROXY_NETMASK='255.255.255.0'

  [ -z "${NSXV_MGT_NET_DEFAULT_GW}" ] && \
    export NSXV_MGT_NET_DEFAULT_GW='172.16.212.1'

  [ -z "${NSXV_EDGE_HA}" ] && \
    export NSXV_EDGE_HA='false'

  [ -z "${NSXV_FLOATING_IP_RANGE}" ] && \
    export NSXV_FLOATING_IP_RANGE='172.16.212.100-172.16.212.150'

  [ -z "${NSXV_FLOATING_NET_CIDR}" ] && \
    export NSXV_FLOATING_NET_CIDR='172.16.212.0/24'

  [ -z "${NSXV_FLOATING_NET_GW}" ] && \
    export NSXV_FLOATING_NET_GW=${NSXV_MGT_NET_DEFAULT_GW:?}

  [ -z "${NSXV_INTERNAL_NET_CIDR}" ] && \
    export NSXV_INTERNAL_NET_CIDR='192.168.0.0/24'

  [ -z "${NSXV_INTERNAL_NET_DNS}" ] && \
    export NSXV_INTERNAL_NET_DNS='8.8.8.8'

  # Export settings
  [ -z "${NODE_VOLUME_SIZE}" ] && \
    export NODE_VOLUME_SIZE=350

  [ -z "${ADMIN_NODE_MEMORY}" ] && \
    export ADMIN_NODE_MEMORY=4096

  [ -z "${ADMIN_NODE_CPU}" ] && \
    export ADMIN_NODE_CPU=4

  [ -z "${SLAVE_NODE_MEMORY}" ] && \
    export SLAVE_NODE_MEMORY=4096

  [ -z "${SLAVE_NODE_CPU}" ] && \
    export SLAVE_NODE_CPU=4

}

RunTest() {

    cd "${WORKSPACE}" || \
      { echo "Error! Cannot cd to WORKSPACE!"; exit $CDWORKSPACE_ERR; }

    [ "${VENV}" = "yes"  ] && . $VENV_PATH/bin/activate
    [ -z "${ENV_NAME}"   ] && ENV_NAME="${JOB_NAME}_system_test"
    [ -z "${LOGS_DIR}"   ] && LOGS_DIR="${WORKSPACE}/logs"
    [ ! -f "${LOGS_DIR}" ] && mkdir -p $LOGS_DIR

    export ENV_NAME
    export LOGS_DIR
    export ISO_PATH

    if [ "${KEEP_BEFORE}" != "yes" ]; then
      dos.py list | grep -q "^${ENV_NAME}\$" && dos.py erase "${ENV_NAME}"
    fi

    # gather additional option for this nose test run
    OPTS=""
    [ -n "${NOSE_ATTR}" ] && \
      OPTS="${OPTS} -a ${NOSE_ATTR}"

    [ -n "${NOSE_EVAL_ATTR}" ] && \
      OPTS="${OPTS} -A ${NOSE_EVAL_ATTR}"

    [ -n "${TEST_OPTIONS}" ] && \
      OPTS="${OPTS} ${TEST_OPTIONS}"

    clean_old_bridges

    export PLUGIN_WORKSPACE="${WORKSPACE/\/fuel-qa}/plugin_test"
    export WORKSPACE="${PLUGIN_WORKSPACE}/fuel-qa"
    export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${WORKSPACE}:${PLUGIN_WORKSPACE}"

    [[ "${DEBUG}" == "true" ]] &&
      echo -e "PYTHONPATH:${PYTHONPATH}\nPATH${PATH}\nPLUGIN_WORKSPACE:${PLUGIN_WORKSPACE}"

    python $PLUGIN_WORKSPACE/run_tests.py -q --nologcapture --with-xunit ${OPTS} &

    SYSTEST_PID=$!

    while [ "$(virsh net-list | grep -c $ENV_NAME)" -ne 5 ]; do
      sleep 10
	    if ! ps -p $SYSTEST_PID > /dev/null
	    then
	      echo System tests exited prematurely, aborting
	      exit 1
	    fi
    done

    # Configre vcenter nodes and interfaces
    setup_net $ENV_NAME
    clean_iptables

    # clean_iptables need call before setup_management_net
    setup_management_net $ENV_NAME
    revert_ws $SYSTEST_PID

    echo "Waiting for system tests to finish"
    wait $SYSTEST_PID

    export RES=$?
    echo "ENVIRONMENT NAME is $ENV_NAME"

    dos.py list --ips ${ENV_NAME}

    if [ "${KEEP_AFTER}" != "yes" ]; then
      # remove environment after tests
        dos.py destroy "${ENV_NAME}"
    fi

    exit "${RES}"
}

add_interface_to_bridge() {
  env=$1
  net_name=$2
  nic=$3
  ip=$4

  for net in $(virsh net-list | grep ${env}_${net_name} | awk '{print $1}'); do
    bridge=$(virsh net-info $net | grep -i bridge | awk '{print $2}')
    setup_bridge $bridge $nic $ip && echo $net_name bridge $bridge ready
  done
}

setup_bridge() {
  bridge=$1
  nic=$2
  ip=$3

  sudo /sbin/brctl stp $bridge off

  if sudo /sbin/brctl show $bridge | grep -q $nic; then
    echo "$nic is already in the $bridge bridge"
  else
    sudo /sbin/brctl addif $bridge $nic
  fi

  for itf in $(sudo ip -o route show to ${NSXV_FLOATING_NET_CIDR} | cut -d' ' -f5); do
    echo "deleting route to ${NSXV_FLOATINV_NET_CIDR} dev $itf"
    sudo ip route del ${NSXV_FLOATING_NET_CIDR} dev $itf
  done

  # set if with existing ip down
  for itf in $(sudo ip -o addr show to $ip | cut -d' ' -f2); do
    echo "deleting $ip from $itf"
    sudo ip addr del dev $itf $ip
  done

  echo "adding $ip to $bridge"
  sudo /sbin/ip addr add $ip dev $bridge
  echo "$nic added to $bridge"
  sudo /sbin/ip link set dev $bridge up

  if sudo /sbin/iptables-save | grep $bridge | grep -i reject | grep -q FORWARD; then
    sudo /sbin/iptables -D FORWARD -o $bridge -j REJECT --reject-with icmp-port-unreachable
    sudo /sbin/iptables -D FORWARD -i $bridge -j REJECT --reject-with icmp-port-unreachable
  fi
}

clean_old_bridges() {
  for intf in $WORKSTATION_IFS; do
    for br in $(/sbin/brctl show | grep -v "bridge name" | cut -f1 -d'	'); do
      /sbin/brctl show $br| grep -q $intf && sudo /sbin/brctl delif $br $intf \
        && sudo /sbin/ip link set dev $br down && echo $intf deleted from $br
    done
  done
}

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

# waiting for ending of parallel processes
wait_revert() {
  while [ $(pgrep vmrun | wc -l) -ne 0 ] ; do
    pgrep vmrun
    sleep $TIMEOUT
  done
  echo ''
}

kill_test(){
  pid=$1

  if [ ! -z $pid ]; then
      echo "killing $pid and its childs" && pkill --parent $pid && kill $pid && exit 1;
  elif [ -z $SYSTEST_PID ]; then
      echo "killing $pid and its childs" && pkill --parent $pid && kill $pid && exit 1;
  else
      echo "test process id doesn't exist"; exit 1;
  fi
}

revert_ws() {
  set +x
  systest_pid=$1

  [ -z $WORKSTATION_USERNAME ] && { echo "WORKSTATION_USERNAME is not set"; kill_test $systest_pid; }
  [ -z $WORKSTATION_PASSWORD ] && { echo "WORKSTATION_PASSWORD is not set"; kill_test $systest_pid; }
  [ -z $WORKSTATION_SNAPSHOT ] && { echo "WORKSTATION_SNAPSHOT is not set"; kill_test $systest_pid; }
  [ -z $WORKSTATION_NODES    ] && { echo "WORKSTATION_NODES is not set";    kill_test $systest_pid; }

  cmd="vmrun -T ws-shared -h https://localhost:443/sdk -u $WORKSTATION_USERNAME -p $WORKSTATION_PASSWORD"

  nodes=$WORKSTATION_NODES
  snapshot=$WORKSTATION_NODES

  # checking that required vms are existing
  for node in $nodes; do
    $cmd listRegisteredVM | grep -q $node || \
      { echo "Error: $node does not exist or does not registered";  kill_test $systest_pid; }
  done

  # reverting vms to the required snapshot
  for node in $nodes; do
    echo "Reverting $node to $snapshot"
    $cmd revertToSnapshot "[standard] $node/$node.vmx" $snapshot || \
      { echo "Error: reverting of $node has failed"; kill_test $systest_pid; } &
  done

  wait_revert

  # starting vms from suspending state
  for node in $nodes; do
    echo "Starting $node"
    $cmd start "[standard] $node/$node.vmx" || \
      { echo "Error: $node failed to start";  kill_test $systest_pid; } &
  done

  wait_revert

  set -x
}

setup_net() {
  env=$1
  add_interface_to_bridge $env public vmnet1 172.16.0.1/24
}

setup_management_net() {
  env=$1
  management_ip=${POOL_MANAGEMENT%\.*}.253
  management_mask=${POOL_MANAGEMENT##*\:}
  floating_ip=${NSXV_FLOATING_NET_GW}
  floating_mask=${NSXV_FLOATING_NET_CIDR##*\/}
  add_interface_to_bridge $env management vmnet5 ${management_ip}/${management_mask}
  add_interface_to_bridge $env management vmnet5 ${floating_ip}/${floating_mask}
  sudo /sbin/iptables -t nat -A POSTROUTING -s ${floating_ip}/${floating_mask} -d ${management_ip}/${management_mask} -j SNAT --to ${management_ip}
}

# MAIN

# first we want to get variable from command line options
GetoptsVariables "${@}"

# check do we have all critical variables set
CheckVariables

RunTest
