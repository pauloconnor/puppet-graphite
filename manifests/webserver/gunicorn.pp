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

case $::osfamily {
    'debian': {
      $web_user = 'www-data'
      $python_dev_pkg = 'python-dev'

      # see https://github.com/graphite-project/carbon/issues/86
      $carbin_pip_hack_source = "/usr/lib/python2.7/dist-packages/carbon-${carbonVersion}-py2.7.egg-info"
      $carbin_pip_hack_target = "/opt/graphite/lib/carbon-${carbonVersion}-py2.7.egg-info"
      $gweb_pip_hack_source = "/usr/lib/python2.7/dist-packages/graphite_web-${carbonVersion}-py2.7.egg-info"
      $gweb_pip_hack_target = "/opt/graphite/webapp/graphite_web-${carbonVersion}-py2.7.egg-info"

      $graphitepkgs = [
        'python-cairo',
        'python-twisted',
        'python-django',
        'python-django-tagging',
        'python-ldap',
        'python-memcache',
        'python-sqlite',
        'python-simplejson',
        'python-mysqldb',
        'python-psycopg2'
      ]
    }
    default: {fail("wsgi/gunicorn-based graphite is not supported on ${::operatingsystem} (only supported on Debian)")}
  }

  package {
    'gunicorn':
      ensure => installed,
      before => Exec['Chown graphite for web user'],
      notify => Exec['Chown graphite for web user'];

  }

  service {
    'gunicorn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      subscribe  => File['/opt/graphite/webapp/graphite/local_settings.py'],
      require    => [
        Package['gunicorn'],
        Exec['Initial django db creation'],
        Exec['Chown graphite for web user']
      ];
  }

  # Deploy configfiles

  file {
    '/etc/gunicorn.d/graphite':
      ensure  => file,
      mode    => '0644',
      content => template('graphite/etc/gunicorn.d/graphite.erb'),
      require => Package['gunicorn'],
      notify  => Service['gunicorn'];
  }

}
