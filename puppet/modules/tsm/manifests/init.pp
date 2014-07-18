class tsm {

# Tivoli Storage Manager Backup/Archive Client support

	package { [ "gskssl64" ]:
			ensure => present,
	}

	package { [ "gskcrypt64" ]:
			ensure => present,
			subscribe => Package[ "gskssl64" ],
	}

	package {
		[ 	"TIVsm-BA"		]:
			ensure => '7.1.0-1',
			alias => tsm,
			subscribe => Package[ "gskcrypt64" ],
	}

	service {
		"dsmcad":
			enable => true,
			ensure => running,
			hasrestart => true,
			hasstatus => true,
			subscribe => Package[ 'tsm' ],
	}

	file {
		"/etc/adsm/TSM.PWD":
			ensure  =>  present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode    =>  600,
			source  =>  'puppet:///modules/tsm/TSM.PWD',
			require =>  Package[ 'tsm' ],
			notify  =>  Service[ 'dsmcad' ],
	}

	file {
		"/etc/adsm/check_tsm.pwd":
			ensure  =>  present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode    =>  600,
			source  =>  'puppet:///modules/tsm/check_tsm.pwd',
			require =>  Package[ 'tsm' ],
			notify  =>  Service[ 'dsmcad' ],
	}

	file {
		"/opt/tivoli/tsm/client/ba/bin/dsm.sys":
			ensure  =>  present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode    =>  444,
			source  =>  'puppet:///modules/tsm/dsm.sys',
			require =>  Package[ 'tsm' ],
			notify  =>  Service[ 'dsmcad' ],
	}

	file {
		"/opt/tivoli/tsm/client/ba/bin/dsm.opt":
			ensure  =>  present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode    =>  444,
			source  =>  'puppet:///modules/tsm/dsm.opt',
			require =>  Package[ 'tsm' ],
			notify  =>  Service[ 'dsmcad' ],
	}

	file {
		"/opt/tivoli/tsm/client/ba/bin/incexcl_wrk.def":
			ensure  =>  present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode    =>  444,
			source  =>  'puppet:///modules/tsm/incexcl_wrk.def',
			require =>  Package[ 'tsm' ],
			notify  =>  Service[ 'dsmcad' ],
	}

	file { # ensure that the TSM connector daemon starts set to UTF-8
		"/opt/tivoli/tsm/client/ba/bin/rc.dsmcad":
			ensure 	=> 	present,
			owner 	=> 	'root',
			group 	=> 	'root',
			mode 	=> 	755,
			source 	=> 	'puppet:///modules/tsm/rc.dsmcad',
			require => 	Package[ 'tsm' ],
			notify  => 	Service[ 'dsmcad' ],
	}

	# log rotation
	file {
		"/etc/logrotate.d/tsm":
			ensure 	=> present,
			owner 	=> 'root',
			group 	=> 'root',
			mode 	=> 644,
			source 	=> 'puppet:///modules/tsm/tsm.logrotate',
	}

	# tsm nagios check
	file {
		"/usr/lib64/nagios/plugins/check_tsm":
			ensure 	=> present,
			owner 	=> nagios,
			group 	=> nagios,
			mode 	=> 755,
			source 	=> 'puppet:///modules/tsm/check_tsm',
	}


#########################################
#	NAGIOS SERVICES

	@@nagios_service
	{ "$fqdn-check_dsmcad":
		use => "generic-service",
		service_description => "dsmcad",
		host_name => "$fqdn",
		target => "/etc/nagios/services/${fqdn}-dsmcad.cfg",
		check_command => "check_nrpe!check_dsmcad",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-nightly_linux":
		use => "generic-service",
		service_description => "nightlybackup",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-nightly_linux.cfg",
		check_command => "check_nrpe!check_tsm-nightly_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-missedfiles_linux":
		use => "generic-service",
		service_description => "missedfiles",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-missedfiles_linux.cfg",
		check_command => "check_nrpe!check_tsm-missedfiles_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-expiredfiles_linux":
		use => "generic-service",
		service_description => "expiredfiles",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-expiredfiles_linux.cfg",
		check_command => "check_nrpe!check_tsm-expiredfiles_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-backupduration_linux":
		use => "generic-service",
		service_description => "backupduration",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-backupduration_linux.cfg",
		check_command => "check_nrpe!check_tsm-backupduration_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-totalbackupsize_linux":
		use => "generic-service",
		service_description => "totalbackupsize",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-totalbackupsize_linux.cfg",
		check_command => "check_nrpe!check_tsm-totalbackupsize_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-tapedrivesstatus_linux":
		use => "generic-service",
		service_description => "tapedrivesstatus",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-tapedrivesstatus_linux.cfg",
		check_command => "check_nrpe!check_tsm-tapedrivesstatus_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-tapefreespace_linux":
		use => "generic-service",
		service_description => "tapefreespace",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-tapefreespace_linux.cfg",
		check_command => "check_nrpe!check_tsm-tapefreespace_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-tapeset_linux":
		use => "generic-service",
		service_description => "tapeset",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-tapeset_linux.cfg",
		check_command => "check_nrpe!check_tsm-tapeset_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-tapesro_linux":
		use => "generic-service",
		service_description => "tapero",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-tapesro_linux.cfg",
		check_command => "check_nrpe!check_tsm-tapesro_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-lastbackup_linux":
		use => "generic-service",
		service_description => "lastbackup",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-lastbackup_linux.cfg",
		check_command => "check_nrpe!check_tsm-lastbackup_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-allfilesystems_linux":
		use => "generic-service",
		service_description => "allfilesystems",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-allfilesystems_linux.cfg",
		check_command => "check_nrpe!check_tsm-allfilesystems_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-queryvolumes_linux":
		use => "generic-service",
		service_description => "queryvolumes",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-queryvolumes_linux.cfg",
		check_command => "check_nrpe!check_tsm-queryvolumes_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-writeerrors_linux":
		use => "generic-service",
		service_description => "writeerrors",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-writeerrors_linux.cfg",
		check_command => "check_nrpe!check_tsm-writeerrors_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-readerrors_linux":
		use => "generic-service",
		service_description => "readerrors",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-readerrors_linux.cfg",
		check_command => "check_nrpe!check_tsm-readerrors_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-dblogsize_linux":
		use => "generic-service",
		service_description => "dblogsize",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-dblogsize_linux.cfg",
		check_command => "check_nrpe!check_tsm-dblogsize_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-dbsize_linux":
		use => "generic-service",
		service_description => "dbsize",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-dbsize_linux.cfg",
		check_command => "check_nrpe!check_tsm-dbsize_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-filespaces_linux":
		use => "generic-service",
		service_description => "filespaces",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-filespaces_linux.cfg",
		check_command => "check_nrpe!check_tsm-filespaces_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-scratch_linux":
		use => "generic-service",
		service_description => "scratch",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-scratch_linux.cfg",
		check_command => "check_nrpe!check_tsm-scratch_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-numberoffiles_linux":
		use => "generic-service",
		service_description => "numberoffiles",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-numberoffiles_linux.cfg",
		check_command => "check_nrpe!check_tsm-numberoffiles_linux",
	}

	@@nagios_service
	{ "$fqdn-check_tsm-checkplatform_linux":
		use => "generic-service",
		service_description => "checkplatform",
		host_name 	=> "$fqdn",
		target => "/etc/nagios/services/${fqdn}-check_tsm-checkplatform_linux.cfg",
		check_command => "check_nrpe!check_tsm-checkplatform_linux",
	}


#########################################
#	SUDO  

	sudo::command
	{ 'check_tsm':
		user 	=>  'nagios',
		command =>  'NOPASSWD: /usr/lib64/nagios/plugins/check_tsm',
	}

#########################################
#	NAGIOS REMOTE COMMANDS

    #########
    # Minumum file permittion for dsmadmc to run as non-user
    # $LOG_DIR = 777
    # $LOG_DIR/*.{log,pru} 777

	# is the acceptor daemon running?
	nagios::remote_command
    { "check_dsmcad":
		command_line => 'check_procs -c 1 -C dsmcad',
    }

    # are we getting nightly backups?
    nagios::remote_command
    { "check_tsm-nightly_linux":
		# command_line => 'check_tsm --platform linux --check nightly',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check nightly',
    }

    # did we skip any files from last night's backup?
    nagios::remote_command
    { "check_tsm-missedfiles_linux":
		# command_line => 'check_tsm --platform linux --check missedfiles',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check missedfiles',
    }

    # report number of expired files from last night's backup
    nagios::remote_command
    { "check_tsm-expiredfiles_linux":
		# command_line => 'check_tsm --platform linux --check expiredfiles',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check expiredfiles',
    }

    # report last night's backup duration in hours
    nagios::remote_command
    { "check_tsm-backupduration_linux":
		# command_line => 'check_tsm --platform linux --check backupduration',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check backupduration',
    }

    # report the total backup size from last night
    nagios::remote_command
    { "check_tsm-totalbackupsize_linux":
		# command_line => 'check_tsm --platform linux --check totalbackupsize',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check totalbackupsize',
    }

	# are the tape drives online?
    nagios::remote_command
    { "check_tsm-tapedrivesstatus_linux":
		# command_line => 'check_tsm --platform linux --check drivestatus',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check drivestatus',
    }

	# how much space are we left?
    nagios::remote_command
    { "check_tsm-tapefreespace_linux":
		# command_line => 'check_tsm --platform linux --check freespace',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check freespace --warning 65 --critical 80',
    }

    # tapeset break-down
    nagios::remote_command
    { "check_tsm-tapeset_linux":
		# command_line => 'check_tsm --platform linux --check tapespace',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check tapeset --warning 65 --critical 80',
    }

    # any tapes read-only?
    nagios::remote_command
    { "check_tsm-tapesro_linux":
		# command_line => 'check_tsm --platform linux --check tapesro',
		# critical limit courtesy of Mr. Ian M. Shore
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check tapesro --warning 1 --critical 5',
    }

    # is last night's backup the last backup run?
    nagios::remote_command
    { "check_tsm-lastbackup_linux":
		# command_line => 'check_tsm --platform linux --check lastbackup',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check lastbackup --warning 1 --critical 5',
    }

    # are all filesystems backed up?
    nagios::remote_command
    { "check_tsm-allfilesystems_linux":
		# command_line => 'check_tsm --platform linux --check fullbackup',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check fullbackup',
    }

    # make a pretty graph of all the utlization of all the volumes allocated
    nagios::remote_command
    { "check_tsm-queryvolumes_linux":
		# command_line => 'check_tsm --platform linux --check volumes',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check volumes',
    }

    # make a pretty graph of all the write errors of all the volumes allocated
    nagios::remote_command
    { "check_tsm-writeerrors_linux":
		# command_line => 'check_tsm --platform linux --check writeerrors',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check writeerrors',
    }

    # make a pretty graph of all the read errors of all the volumes allocated
    nagios::remote_command
    { "check_tsm-readerrors_linux":
		# command_line => 'check_tsm --platform linux --check readerrors',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check readerrors',
    }

    # make a pretty graph of the space used for the database
    nagios::remote_command
    { "check_tsm-dbsize_linux":
		# command_line => 'check_tsm --platform linux --check dbsize',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check dbsize --warning 60 --critical 80',
    }

    # make a pretty graph of the space used by the log file the database
    nagios::remote_command
    { "check_tsm-dblogsize_linux":
		# command_line => 'check_tsm --platform linux --check dblogsize',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check dblogsize --warning 60 --critical 80',
    }

    # make a pretty graph of the occupancy of the individual filespaces in backed up in tsm
    nagios::remote_command
    { "check_tsm-filespaces_linux":
		# command_line => 'check_tsm --platform linux --check filespaces',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check filespaces',
    }

    # keep track of the scratch space.
    nagios::remote_command
    { "check_tsm-scratch_linux":
		# command_line => 'check_tsm --platform linux --check scratch --warning 80 --critical 40',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check scratch --warning 80 --critical 40',
    }

    # perf data for number of files per filesystem.
    nagios::remote_command
    { "check_tsm-numberoffiles_linux":
		# command_line => 'check_tsm --platform linux --check numberoffiles',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check numberoffiles',
    }

    # report number of expired files from last night's backup
    nagios::remote_command
    { "check_tsm-checkplatform_linux":
		# command_line => 'check_tsm --platform linux --check platform',
		raw_command_line => '/usr/bin/sudo /usr/lib64/nagios/plugins/check_tsm --check platform',
    }


}

