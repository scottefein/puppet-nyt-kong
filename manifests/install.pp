class kong(
	$config_url = '/etc/kong/kong.yml',
	$kong_template = "kong/kong.yaml.erb",
	$consul_enabled = false,

){
	validate_string($cassandra_nodes)
	if $kong_version != "newest" {
		$kong_version_string = "?version=$::kong_version"
	} else{
		$kong_version_string = ""
	}
	$kong_source_url = "$kong_download_url$kong_version_string"
	
	if ($::operatingsystem == 'CentOS'){

		if $consul_enabled == true {
			consul_template::watch { 'kong_config':
				template =>  $kong_template,
				destination => $config_url,
				command => "service kong restart",	
			}
		}
		service{'kong':
			ensure    => 'running',
			enable    => true,
			require   => [
				File['/etc/init.d/kong'],
				Package['kong'],
			],
		}

	} else{
		fail('Only CentOS 6 is currently supported')
	}
}