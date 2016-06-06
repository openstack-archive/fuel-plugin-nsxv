#!/usr/bin/env ruby
=begin
Copyright 2016 Mirantis, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.

The script looks for edge with "metadata_proxy_router" in the name and checks
its state and edgeStatus. If "state=deployed" and "edgeStatus=green" then
return code 0, otherwise 1.
=end

require 'rest-client'
require 'nokogiri'

ip = ARGV[0]
user = ARGV[1]
pass = ARGV[2]
datacenter_id = ARGV[3]

list_edges_url = "https://#{ip}/api/4.0/edges/?datacenter=#{datacenter_id}"

# in worst case this scripts overall timeout is 15 seconds (3 tries * 5 second each try
def get_nsxv_api(url, user, pass)
  retry_count = 3
  begin
    response = RestClient::Request.execute(method: :get, url: url, timeout: 15, user: user, password: pass)
    if response.code == 200
      xml_response = Nokogiri::XML(response.body)
    else
      fail
    end
  rescue => e
    retry_count -= 1
    if retry_count > 0
      sleep 5
      retry
    else
      puts "Cannot get response for request #{url}"
      puts "NSX Manager responded: #{e.message}"
      raise
    end
  end
  return xml_response
end

# list all edges

EDGE_METADATA_TYPE = 'metadata_proxy_router*'
EDGE_DEPLOYED_STATE = 'deployed'
EDGE_READY_STATUS = 'green'

EXIT_SUCCESS = 0
EXIT_FAILURE = 1

response = get_nsxv_api(list_edges_url, user, pass)
response.xpath("//edgeSummary").each do |edge|
  if /#{EDGE_METADATA_TYPE}/i.match(edge.xpath("name").text)
    if /#{EDGE_DEPLOYED_STATE}/i.match(edge.at_xpath("state").text) and
      /#{EDGE_READY_STATE}/i.match(edge.at_xpath("edgeStatus").text)
      exit EXIT_SUCCESS
    end
  end
end

exit EXIT_FAILURE
