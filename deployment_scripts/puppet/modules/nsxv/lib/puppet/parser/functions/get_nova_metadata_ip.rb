module Puppet::Parser::Functions
  newfunction(:get_nova_metadata_ip, :type => :rvalue, :doc => <<-EOS
Returns the ip address of the metadata server, computed based on the network
where it should be. The first argument - network, which should listen to the
metadata server, ex:
  get_nova_metadata_ip('management')
EOS
  ) do |args|
    metadata_netwrok = args[0]
    if metadata_netwrok == 'management'
      ip = function_hiera(['management_vip'])
    elsif metadata_netwrok == 'public'
      ip = function_hiera(['public_vip'])
    else
      raise "Network parameter for metadata-server listen must be within the meaning 'public' or 'management'"
    end
    return ip
  end
end
