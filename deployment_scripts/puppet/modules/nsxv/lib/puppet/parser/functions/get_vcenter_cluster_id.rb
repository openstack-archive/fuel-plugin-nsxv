require 'rbvmomi'

module Puppet::Parser::Functions
  newfunction(:get_vcenter_cluster_id, :type => :rvalue) do |args|

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
        dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).find { |x| x.to_s == 'Datacenter("'+datacenter_id+'")' } or fail 'Can not search datacenter with id: ' + datacenter_id
        cluster = dc.find_compute_resource(vc_cluster) or fail 'Can not search cluster: ' + vc_cluster
        cluster_id = cluster.to_s.gsub!(/^[^"]+"([^"]+)"[^"]*/, '\1')
        clusters_id.push(cluster_id)
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
