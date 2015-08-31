require 'yaml'

module Puppet::Parser::Functions
newfunction(:ruby2yaml, :type => :rvalue, :doc => <<-EOS
    Get puppet structure and returns corresponding yaml structure
    EOS
  ) do |args|
      args[0].to_yaml
    end
end
