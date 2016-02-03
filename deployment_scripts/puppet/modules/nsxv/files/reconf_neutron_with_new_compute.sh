#!/bin/bash -e
pluginConfFile='/etc/neutron/plugin.ini'
lockFile='/tmp/nsxv_lock'

#check lockFile modified above 5 min ago(task timeout)
if [ -n "$(find `dirname $lockFile` -name `basename $lockFile` -mmin +5)" -o ! -e $lockFile ]; then
  #create lock
  touch $lockFile

  configuredClusters=$(sed -rn 's/^\s*cluster_moid\s*=\s*([^ ]+)\s*$/\1/p' $pluginConfFile)

  newConfiguredClusters=$(ruby -e "

  require 'hiera'
  require 'hiera/util'
  require 'rbvmomi'

  plugin_scope='NAME'

  def hiera(key,type=:priority)
    hiera = Hiera.new(:config => File.join(Hiera::Util.config_dir, 'hiera.yaml'))
    hiera.lookup(key, nil, {}, nil, type)
  end

  datacenter_id=hiera(plugin_scope)['nsxv_datacenter_moid']
  vcenter_hash = hiera('vcenter',':hash')
  clusters_id=[]
  retry_count = 4

  vcenter_hash['computes'].each do |cluster_settings|
    vc_cluster = cluster_settings['vc_cluster']
    vc_host = cluster_settings['vc_host']
    vc_password =  cluster_settings['vc_password']
    vc_user = cluster_settings['vc_user']

    begin
      vim = RbVmomi::VIM.connect(host: vc_host, ssl: true, insecure: true, user: vc_user, password: vc_password)
      rootFolder = vim.serviceInstance.content.rootFolder
      dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).find { |x| x.to_s == 'Datacenter(\"'+datacenter_id+'\")' } or fail 'Can not search datacenter with id: ' + datacenter_id
      cluster = dc.find_compute_resource(vc_cluster) or fail 'Can not search cluster: ' + vc_cluster
      cluster_id = cluster.to_s.gsub!(/^[^\"]+\"([^\"]+)\"[^\"]*/, '\1')
      clusters_id.push(cluster_id)
    rescue
      retry_count -= 1
      if retry_count > 0
        sleep 5
        retry
      else
        raise
      end
    end
  end

  puts clusters_id.sort.join(',')")

  if [ "$configuredClusters" != "$newConfiguredClusters" ]; then
    sed --follow-symlinks -ri "s|^\s*cluster_moid.*|cluster_moid = $newConfiguredClusters|" $pluginConfFile
    $(which service) neutron-server restart
  fi

  #delete lock
  rm -f $lockFile
fi
