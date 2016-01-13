class kong::install(){
	service{'kong':
		ensure    => 'running',
		enable    => true,
		require   => [
			File['/etc/init.d/kong'],
			Package['kong'],
		],
	}
}