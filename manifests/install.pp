class kong::install{

	if $::kong_version {
		$kong_version_string = "?version=#{$::kong_version}"
	} else{
		$kong_version_string = ""
	}

	package{'epel-release':
		provider => 'yum',
		ensure => present,
	}

	package{['dnsmasq','nc','openssl098e']:
		ensure => present,
		provider => yum,
		before => Package["kong"],
		require => Package["epel-release"],
	}

	package{ 'kong':
		provider => 'rpm',
		ensure => present,
		source => "http://downloadkong.org/el6.noarch.rpm#{$kong_version_string}",
		require => File["/etc/kong/kong.yml"],
	}

	file { '/etc/kong/kong.yml':
	  ensure  => present,
	  content => template('kong/kong.yaml.erb'),
	}

	exec { "start kong":
	    command => "kong start",
	    path    => "/usr/local/bin/",
	    require => Package["kong"],
	}
}