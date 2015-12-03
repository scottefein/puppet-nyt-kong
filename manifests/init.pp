class kong(
	$kong_version = 'newest',
	$ensure_config = 'file',
	$ensure_package = 'present',
	$kong_download_url = 'http://downloadkong.org/el6.noarch.rpm',
	$config_url = '/etc/kong/kong.yml',
	$kong_install_path = '/usr/local/bin/',
	$kong_start_command = 'kong restart',
	$nginx_working_dir = '/usr/local/kong/',
	$proxy_port = 8000,
	$proxy_ssl_port = 8443,
	$admin_api_port = 8001,
	$dnsmasq_port = 8053,

){
	validate_string($cassandra_nodes)
	if $kong_version != "newest" {
		$kong_version_string = "?version=$::kong_version"
	} else{
		$kong_version_string = ""
	}
	$kong_source_url = "$kong_download_url$kong_version_string"
	
	if ($::operatingsystem == 'CentOS'){

		package{'epel-release':
			ensure => present,
		}

		package{['dnsmasq','nc','openssl098e']:
			ensure => present,
			before => Package["kong"],
			require => Package["epel-release"],
		}

		package{ 'kong':
			provider => 'rpm',
			ensure => $ensure_package,
			source => $kong_source_url,
			require => File['kong_config'],
		}

		file { 'kong_directory':
			ensure => directory,
			path   => '/etc/kong',
			before => File['kong_config'],
		}

		file { 'kong_config':
			ensure  => file,
			content => template('kong/kong.yaml.erb'),
			path 	=> $config_url,
			notify  => Exec['reload_kong'],
		}

		exec { 'start_kong':
		    command => $kong_start_command,
		    path    => $kong_install_path,
		    require => Package['kong'],
		}

		exec {'reload_kong':
			command => 'kong reload',
			path    => $kong_install_path,
			refreshonly => true,
		}
	} else{
		fail('Only CentOS 6 is currently supported')
	}
}