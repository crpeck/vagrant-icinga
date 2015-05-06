class { 'icinga2::server':
  install_mail_utils_package => true,
  server_enabled_features    => ['checker','notification'],
  server_db_type             => 'mysql',
  db_host                    => 'localhost',
  db_port                    => '5432',
  db_name                    => 'icinga2_data',
  db_user                    => 'icinga2',
  db_password                => 'icinga2-password',
}

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

#class { 'icinga2::nrpe':
#  allow_command_argument_processing => 1,
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


package { [
  'bash-completion',
  'bsd-mailx',
  'git',
  'rlwrap',
  'tree',
  ]:
  ensure => 'installed'
}

#@user { vagrant: ensure => present }
#User<| title == vagrant |>{
#  groups +> ['icinga', 'icingacmd'],
#  require => Package['icinga2']
#}

#file { [ '/root/.vim',
#        '/root/.vim/syntax',
#        '/root/.vim/ftdetect' ] :
#  ensure    => 'directory'
#}

#exec { 'copy-vim-syntax-file':
#  path    => '/bin:/usr/bin:/sbin:/usr/sbin',
#  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/syntax/icinga2.vim /root/.vim/syntax/icinga2.vim',
#  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
#}

#exec { 'copy-vim-ftdetect-file':
#  path    => '/bin:/usr/bin:/sbin:/usr/sbin',
#  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/ftdetect/icinga2.vim /root/.vim/ftdetect/icinga2.vim',
#  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
#}

####################################
# Icinga 2 General
####################################

# enable the command pipe
#icinga2::feature { 'command': }


# present icinga2 in icingaweb2's module documentation
#file { '/usr/share/icingaweb2/modules/icinga2':
#  ensure  => 'directory',
#  require => Package['icingaweb2']
#}

#file { '/usr/share/icingaweb2/modules/icinga2/doc':
#  ensure  => 'link',
#  target  => '/usr/share/doc/icinga2/markdown',
#  require => [ Package['icinga2'], Package['icingaweb2'], File['/usr/share/icingaweb2/modules/icinga2'] ],
#}

#file { '/etc/icingaweb2/enabledModules/icinga2':
#  ensure  => 'link',
#  target  => '/usr/share/icingaweb2/modules/icinga2',
#  require => File['/etc/icingaweb2/enabledModules'],
#}

