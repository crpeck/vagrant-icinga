package { [
  'bash-completion',
  'bsd-mailx',
  'git',
  'rlwrap',
  'tree',
  ]:
  ensure => 'installed'
}

class {'apache':
  mpm_module    => 'prefork',
  default_mods  => [  'actions',
                      'alias',
                      'asis',
                      'auth_basic',
                      'auth_digest',
                      'authn_anon',
                      'authn_core',
                      'authn_dbm',
                      'authn_file',
                      'authz_groupfile',
                      'authz_user',
                      'dir',
                      'env',
                      'expires',
                      'headers',
                      'include',
                      'info',
                      'mime',
                      'mime_magic',
                      'negotiation',
                      'php',
                      'proxy',
                      'proxy_connect',
                      'proxy_http',
                      'rewrite',
                      'setenvif',
                      'status',
                      'unique_id',
                      'usertrack' ],
  purge_configs => false,
}

class { 'apache::mod::ssl':
  ssl_compression => false,
  ssl_options     => [ 'StdEnvVars' ],
}

#php::ini { '/etc/php.ini':
#  display_errors    => 'On',
#  memory_limit      => '256M',
#  date_timezone     => 'US/New York',
#  session_save_path => '/var/lib/php/session',
#  require           => Class['::apache'],
#  notify            => Service['httpd'],
#}


###
class { '::mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
}
mysql::db { 'icinga2_data':
  user     => 'icinga2',
  password => 'icinga2-password',
  host     => 'localhost',
  grant    => ['ALL'],
}

class { 'icinga2::server':
  install_mail_utils_package => true,
  server_enabled_features    => ['checker', 'icinga2', 'doc', 'livestatus', 'monitoring', 'notification'],
  server_db_type             => 'mysql',
  db_host                    => 'localhost',
  db_port                    => '3306',
  db_name                    => 'icinga2_data',
  db_user                    => 'icinga2',
  db_password                => 'icinga2-password',
}


#class { 'icinga2::nrpe':
#  allow_command_argument_processing => 1,
#  nrpe_purge_unmanaged => true,
#}

icinga2::object::idomysqlconnection { 'mysql_connection':
  target_dir       => '/etc/icinga2/features-enabled',
  target_file_name => 'ido-mysql.conf',
  host             => '127.0.0.1',
  port             => 3306,
  user             => 'icinga2',
  password         => 'icinga2-password',
  database         => 'icinga2_data',
  categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
}

icinga2::object::perfdatawriter { 'pnp':
  host_perfdata_path      => '/var/spool/icinga2/perfdata/host-perfdata',
  service_perfdata_path   => '/var/spool/icinga2/perfdata/service-perfdata',
  host_format_template    => 'DATATYPE::HOSTPERFDATA\tTIMET::$icinga.timet$\tHOSTNAME::$host.name$\tHOSTPERFDATA::$host.perfdata$\tHOSTCHECKCOMMAND::$host.check_command$\tHOSTSTATE::$host.state$\tHOSTSTATETYPE::$host.state_type$',
  service_format_template => 'DATATYPE::SERVICEPERFDATA\tTIMET::$icinga.timet$\tHOSTNAME::$host.name$\tSERVICEDESC::$service.name$\tSERVICEPERFDATA::$service.perfdata$\tSERVICECHECKCOMMAND::$service.check_command$\tHOSTSTATE::$host.state$\tHOSTSTATETYPE::$host.state_type$\tSERVICESTATE::$service.state$\tSERVICESTATETYPE::$service.state_type$',
  rotation_interval       => '15s'
}

class { 'icingaweb2':
  admin_users         => 'crpeck, pcfens',
  auth_backend        => 'external',
  auth_resource       => 'wm_ldap',
  install_method      => 'git',
  manage_apache_vhost => true,
}

# enable the command pipe
#icinga2::feature { 'command': }

#file { '/etc/icingaweb2/authentication.ini':
#  ensure  => present,
#  target  => '/etc/icingaweb2/authentication.ini',
#  require => Class['icingaweb2'],
#  owner   => 'icingaweb2',
#  group   => 'www-data',
#  mode    => '0664',
#  content => '
#[ldap]
#backend             = "ldap"
#resource            = "wm_ldap"
#user_class          = "inetOrgPerson"
#user_name_attribute = "uid"
#filter              = ""
#base_dn             = "ou=people,dc=wm,dc=edu"
#
#',
#}


# present icinga2 in icingaweb2's module documentation
file { '/usr/share/icingaweb2/modules/icinga2':
  ensure  => 'directory',
  require => Class['icingaweb2']
}

file { '/usr/share/icingaweb2/modules/icinga2/doc':
  ensure  => 'link',
  target  => '/usr/share/doc/icinga2/markdown',
  require => [ Package['icinga2'], Class['icingaweb2'], File['/usr/share/icingaweb2/modules/icinga2'] ],
}

file { '/etc/icingaweb2/enabledModules/icinga2':
  ensure  => 'link',
  target  => '/usr/share/icingaweb2/modules/icinga2',
  require => File['/etc/icingaweb2/enabledModules'],
}

