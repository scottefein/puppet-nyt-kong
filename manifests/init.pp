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
	$cassandra_nodes = "127.0.0.1"

){
	validate_string($cassandra_nodes)
	if $kong_version != "newest" {
		$kong_version_string = "?version=$::kong_version"
	} else{
		$kong_version_string = ""
	}
	$kong_source_url = "$kong_download_url$kong_version_string"
	
	if ($::operatingsystem == 'CentOS'){

		ensure_packages(['epel-release'])

		package{['nc','openssl098e']:
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

		file {'nginx_working_dir':
			ensure => directory,
			path   => $nginx_working_dir,
			before => File['kong_ssl_config'],
		}

		file { 'kong_config':
			ensure  => file,
			content => template('kong/kong.yaml.erb'),
			path 	=> $config_url,
			notify  => Exec['reload_kong'],
		}

		file {'kong_ssl_config':
			ensure => directory,
			path => "${nginx_working_dir}ssl",
			require => File['kong_config'],
		}

		file { 'kong_ssl_cert':
		  ensure  => file,
		  force => true,
	      purge => true,
		  source => "puppet:///modules/kong/kong-default.crt",
		  path => '/usr/local/kong/ssl/kong-default.crt',
		  require => File['kong_ssl_config'],
		  before => Exec['start_kong'],
		}

		file { 'kong_ssl_key':
		  ensure  => file,
		  force => true,
	      purge => true,
		  source => "puppet:///modules/kong/kong-default.key",
		  path => '/usr/local/kong/ssl/kong-default.key',
		  require => File['kong_ssl_config'],
		  before => Exec['start_kong'],
		}

		exec { 'start_kong':
		    command => $kong_start_command,
		    path    => $kong_install_path,
		    require => Package['kong'],
		}->
		exec {'reload_kong':
			command => 'kong reload',
			path    => $kong_install_path,
			refreshonly => true,
			require => Package['kong'],
		}

	} else{
		fail('Only CentOS 6 is currently supported')
	}
}