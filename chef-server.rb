require 'uri'
_uri = ::URI.parse(ENV['PUBLIC_URL'] || 'https://127.0.0.1/')

topology "standalone"

if _uri.port == _uri.default_port
  api_fqdn _uri.hostname
else
  api_fqdn "#{_uri.hostname}:#{_uri.port}"
end

nginx['url'] = _uri.to_s
bookshelf['url'] = _uri.to_s
bookshelf['external_url'] = _uri.to_s
erchef['base_resource_url'] = _uri.to_s

nginx['enable_non_ssl'] = true
chef_server_webui['enable'] = !ENV['DISABLE_WEBUI']
