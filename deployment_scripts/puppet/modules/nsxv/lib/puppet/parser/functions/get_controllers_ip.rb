module Puppet::Parser::Functions
  newfunction(:get_controllers_ip, :type => :rvalue, :doc => <<-EOS
Return a list of ip nodes with 'primary-controller', 'controller' roles.
The first argument - list of the nodes, ex:
  get_controllers_ip(hiera('nodes'))
EOS
  ) do |args|
    nodes = args[0]
    controllers = []
    nodes.each do |node|
      if node['role'].include?('controller') or node['role'].include?('primary-controller')
        controllers.push(node['internal_address'])
      end
    end
    return controllers
  end
end
