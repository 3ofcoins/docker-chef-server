instance_eval(File.read("/etc/opscode/pivotal.rb"))
chef_server_url "#{chef_server_url}/organizations/#{ENV['CHEF_ORGANIZATION']}" if ENV['CHEF_ORGANIZATION']
versioned_cookbooks true
