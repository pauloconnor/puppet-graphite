# == Class: graphite::webserver::gunicorn
#
# This class configures graphite/carbon/whisper and SHOULD NOT be
# called directly.
#
# === Parameters
#
# None.
#
class graphite::webserver::gunicorn inherits graphite::params {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  if $::osfamily != 'debian' {
    fail("wsgi/gunicorn-based graphite is not supported on ${::operatingsystem} (only supported on Debian)")
  }

  package {
    'gunicorn':
      ensure   => installed,
      provider => 'pip',
      before   => Exec['Chown graphite for web user'],
      notify   => Exec['Chown graphite for web user'];
  }

  service {
    'gunicorn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      subscribe  => File["${graphite::install_dir}/webapp/graphite/local_settings.py"],
      require    => [
        Package['gunicorn'],
        Exec['Initial django db creation'],
        Exec['Chown graphite for web user']
      ];
  }

  # Deploy configfiles
  file { '/etc/gunicorn.d':
    ensure => 'directory',
  }->
  file {
    '/etc/gunicorn.d/graphite':
      ensure  => file,
      mode    => '0644',
      content => template('graphite/etc/gunicorn.d/graphite.erb'),
      require => Package['gunicorn'],
      notify  => Service['gunicorn'];
  }

}