# THIS FILE WILL BE OVERWRITTEN ON CONTAINER START.  Please create a
# new file named `chef-server-local.rb` for custom settings.

# Read parameters that originally came from Docker's environment
# variables, and were saved to a file to support docker-enter

_env = Hash[ Dir['/.chef/env/*']
    .map { |f| [ File.basename(f), File.read(f).strip ] } ]

require 'uri'
_uri = ::URI.parse(_env['PUBLIC_URL'] || 'https://127.0.0.1/')

# Set environment variables that may be missing when chef-server-ctl
# runs from docker-enter
ENV['HOME']     ||= '/'
ENV['HOSTNAME'] ||= File.read('/etc/hostname').strip
ENV['PATH']     ||= '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV['EDITOR']   ||= 'vim'

if _uri.port == _uri.default_port
  api_fqdn _uri.hostname
else
  api_fqdn "#{_uri.hostname}:#{_uri.port}"
end

bookshelf['external_url'] = _uri.to_s
bookshelf['url'] = _uri.to_s
nginx['enable_non_ssl'] = true
nginx['url'] = _uri.to_s
nginx['x_forwarded_proto'] = _uri.scheme
oc_id['administrators'] = _env['OC_ID_ADMINISTRATORS'].to_s.split(',')
opscode_erchef['base_resource_url'] = _uri.to_s

_local = File.join(File.dirname(__FILE__), 'chef-server-local.rb')
instance_eval(File.read(_local), _local) if File.exist?(_local)
