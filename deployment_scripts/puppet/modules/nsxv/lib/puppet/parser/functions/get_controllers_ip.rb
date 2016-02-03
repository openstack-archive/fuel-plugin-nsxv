module Puppet::Parser::Functions
  newfunction(:get_controllers_ip, :type => :rvalue) do |args|
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
