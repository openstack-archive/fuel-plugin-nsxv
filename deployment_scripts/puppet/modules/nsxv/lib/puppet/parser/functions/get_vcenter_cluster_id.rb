require 'rbvmomi'

module Puppet::Parser::Functions
  newfunction(:get_vcenter_cluster_id, :type => :rvalue, :doc => <<-EOS
Return a string of vcenter cluster moref id, clusters names get from hiera
vcenter hash. The first argument - vcenter datacenter moref id, where
search clusters, ex:
  get_vcenter_cluster_id('datacenter-126')
EOS
  ) do |args|

    datacenter_id=args[0]
    vcenter_hash = function_hiera_hash(['vcenter'])
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
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).find { |x| x._ref == datacenter_id } or fail 'Can not search datacenter with id: ' + datacenter_id
        all_clusters_object = dc.hostFolder.inventory_flat({'ComputeResource' => []}).select do |k, v|
          k.is_a?(RbVmomi::VIM::ComputeResource)
        end
        check_array = []
        all_clusters_object.each do |cluster, options|
          if cluster.name == vc_cluster
            check_array.push(cluster._ref)
          end
        end
        # check the name of the uniqueness in the data center
        if check_array.length > 1
          fail 'Cluster ' + vc_cluster + ' is not unique in datacenter'
        elsif check_array.length == 0
          fail 'Cluster ' + vc_cluster + ' not found'
        end
        clusters_id.push(check_array[0])
      rescue
        retry_count -= 1
        if retry_count > 0
          sleep 5
          retry
        else
          warning('Can not get moRefId for ' + vc_cluster + ' cluster')
          raise
        end
      end
    end

    return clusters_id.sort.join(',')
  end
end
