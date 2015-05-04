#include '::mysql::server'
#include icinga2
#include icinga2_ido_mysql
#include icinga2-classicui
#include icinga2-icinga-web
#include icingaweb2
#include icingaweb2-internal-db-mysql
#include monitoring-plugins

#icingaweb2::module { [ 'businessprocess', 'pnp4nagios', 'generictts' ]:
#  builtin => false
#}

####################################
# Webserver
####################################

#class {'apache':
  # don't purge php, icingaweb2, etc configs
#  purge_configs => false,
#}

#class {'::apache::mod::php': }

#include '::php::cli'
#include '::php::mod_php5'

#php::ini { '/etc/php.ini':
#  display_errors => 'On',
#  memory_limit => '256M',
#  date_timezone => 'US/Eastern',
#  session_save_path => '/var/lib/php/session'
#}


####################################
# Misc
####################################
# fix puppet warning.
# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
#if versioncmp($::puppetversion,'3.6.1') >= 0 {
#  $allow_virtual_packages = hiera('allow_virtual_packages',false)
#  Package {
#    allow_virtual => $allow_virtual_packages,
#  }
#}
#
package { [ 'vim-enhanced', 'mailx', 'tree', 'gdb', 'rlwrap', 'git' ]:
  ensure => 'installed'
}
#
package { 'bash-completion':
  ensure => 'installed',
}

@user { vagrant: ensure => present }
User<| title == vagrant |>{
  groups +> ['icinga', 'icingacmd'],
  require => Package['icinga2']
}

file { [ '/root/.vim',
       '/root/.vim/syntax',
       '/root/.vim/ftdetect' ] :
  ensure    => 'directory'
}

exec { 'copy-vim-syntax-file':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/syntax/icinga2.vim /root/.vim/syntax/icinga2.vim',
  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
}

exec { 'copy-vim-ftdetect-file':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/ftdetect/icinga2.vim /root/.vim/ftdetect/icinga2.vim',
  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
}

####################################
# Icinga 2 General
####################################

# enable the command pipe
#icinga2::feature { 'command': }


# present icinga2 in icingaweb2's module documentation
file { '/usr/share/icingaweb2/modules/icinga2':
  ensure => 'directory',
  require => Package['icingaweb2']
}

file { '/usr/share/icingaweb2/modules/icinga2/doc':
  ensure => 'link',
  target => '/usr/share/doc/icinga2/markdown',
  require => [ Package['icinga2'], Package['icingaweb2'], File['/usr/share/icingaweb2/modules/icinga2'] ],
}

file { '/etc/icingaweb2/enabledModules/icinga2':
  ensure => 'link',
  target => '/usr/share/icingaweb2/modules/icinga2',
  require => File['/etc/icingaweb2/enabledModules'],
}

