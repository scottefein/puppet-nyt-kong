class kong::consul_setup(
	$config_url = '/etc/kong/kong.yml',
	$kong_template = "kong/kong.yaml.ctmpl.erb",
	$nginx_kong_config_path = "/etc/consul-template/kong_nginx_config",
	$kong_command = "service kong reload",
	$cass_consul_name = "cass",
	$cass_server_states = "any",
	$nginx_config_template = "kong/nginx_config"
){
	file{'kong_nginx_config':
		path => $nginx_kong_config_path,
		ensure  => file,
	 	content => template($nginx_config_template),
	}

	consul_template::watch { 'kong':
		template =>  $kong_template,
		destination => $config_url,
		command => $kong_command,	
		before => Service['kong'],
		require => File['kong_nginx_config'],
	}
}