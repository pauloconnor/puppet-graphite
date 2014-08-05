# == Class: graphite::config_apache
#
# This class configures apache to proxy requests to graphite web and SHOULD
# NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::webserver::apache (  
  $apache_port               = 80,
  $apache_port_https         = 443,
  $apache_24                 = false
  ) inherits graphite::params {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  # we need an apache with python support

  case $osfamily {
    'debian': {
      $apache_pkg = 'apache2'
      $apache_wsgi_pkg = 'libapache2-mod-wsgi'
      $apache_wsgi_socket_prefix = '/var/run/apache2/wsgi'
      $apache_service_name = 'apache2'
      $apacheconf_dir = '/etc/apache2/sites-available'
      $apacheports_file = 'ports.conf'
      $apache_dir = '/etc/apache2'
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
    'redhat': {
      $apache_pkg = 'httpd'
      $apache_wsgi_pkg = 'mod_wsgi'
      $apache_wsgi_socket_prefix = 'run/wsgi'
      $apache_service_name = 'httpd'
      $apacheconf_dir = '/etc/httpd/conf.d'
      $apacheports_file = 'graphite_ports.conf'
      $apache_dir = '/etc/httpd'
      $web_user = 'apache'
      $python_dev_pkg = 'python-devel'

      # see https://github.com/graphite-project/carbon/issues/86
      case $operatingsystemrelease {
        /^6\.\d+$/: {
          $carbin_pip_hack_source = "/usr/lib/python2.6/site-packages/carbon-${carbonVersion}-py2.6.egg-info"
          $carbin_pip_hack_target = "/opt/graphite/lib/carbon-${carbonVersion}-py2.6.egg-info"
          $gweb_pip_hack_source = "/usr/lib/python2.6/site-packages/graphite_web-${graphiteVersion}-py2.6.egg-info"
          $gweb_pip_hack_target = "/opt/graphite/webapp/graphite_web-${graphiteVersion}-py2.6.egg-info"
        }
        /^7\.\d+$/: {
          $carbin_pip_hack_source = "/usr/lib/python2.7/site-packages/carbon-${carbonVersion}-py2.7.egg-info"
          $carbin_pip_hack_target = "/opt/graphite/lib/carbon-${carbonVersion}-py2.7.egg-info"
          $gweb_pip_hack_source = "/usr/lib/python2.7/site-packages/graphite_web-${graphiteVersion}-py2.7.egg-info"
          $gweb_pip_hack_target = "/opt/graphite/webapp/graphite_web-${graphiteVersion}-py2.7.egg-info"
        }
        default: {fail('Unsupported Redhat release')}
      }

      $graphitepkgs = [
        'pycairo',
        'Django14',
        'python-ldap',
        'python-memcached',
        'python-sqlite2',
        'bitmap',
        'bitmap-fonts-compat',
        'python-crypto',
        'pyOpenSSL',
        'gcc',
        'python-zope-interface',
        'MySQL-python',
        'python-psycopg2'
      ]
    }
    default: {fail('unsupported os.')}
  }

  package {
    $graphite::params::apache_pkg:
      ensure => installed,
      before => Exec['Chown graphite for web user'],
      notify => Exec['Chown graphite for web user'];
  }

  package {
    $graphite::params::apache_wsgi_pkg:
      ensure  => installed,
      require => Package[$graphite::params::apache_pkg]
  }

  case $osfamily {
    debian: {
      # mod_header is disabled on Ubuntu by default,
      # but we need it for CORS headers
      if $graphite::web_cors_allow_from_all {
        exec { 'enable mod_headers':
          command => 'a2enmod headers',
          require => Package[$graphite::params::apache_wsgi_pkg]
        }
      }
      exec { 'Disable default apache site':
        command => 'a2dissite default',
        onlyif  => 'test -f /etc/apache2/sites-enabled/000-default',
        require => Package[$graphite::params::apache_wsgi_pkg],
        notify  => Service[$graphite::params::apache_service_name];
      }
    }
    redhat: {
      file { "${::graphite::params::apacheconf_dir}/welcome.conf":
        ensure  => absent,
        require => Package[$graphite::params::apache_wsgi_pkg],
        notify  => Service[$graphite::params::apache_service_name];
      }
    }
    default: {
      fail("Module graphite is not supported on ${::operatingsystem}")
    }
  }

  service { $graphite::params::apache_service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec['Chown graphite for web user'];
  }

  # Deploy configfiles
  file {
    "${::graphite::params::apache_dir}/ports.conf":
      ensure  => file,
      owner   => $graphite::params::web_user,
      group   => $graphite::params::web_user,
      mode    => '0644',
      content => template('graphite/etc/apache2/ports.conf.erb'),
      require => [
        Package[$graphite::params::apache_wsgi_pkg],
        Exec['Initial django db creation'],
        Exec['Chown graphite for web user']
      ];
    "${::graphite::params::apacheconf_dir}/graphite.conf":
      ensure  => file,
      owner   => $graphite::params::web_user,
      group   => $graphite::params::web_user,
      mode    => '0644',
      content => template('graphite/etc/apache2/sites-available/graphite.conf.erb'),
      require => [
        File["${::graphite::params::apache_dir}/ports.conf"],
      ];
  }

  case $osfamily {
    debian: {
      file { '/etc/apache2/sites-enabled/graphite.conf':
        ensure  => link,
        target  => "${::graphite::params::apacheconf_dir}/graphite.conf",
        require => File['/etc/apache2/sites-available/graphite.conf'],
        notify  => Service[$graphite::params::apache_service_name];
      }
    }
    redhat: {
      if $graphite::gr_apache_port != '80' {
        file { "${::graphite::params::apacheconf_dir}/${::graphite::params::apacheports_file}":
          ensure  => link,
          target  => "${::graphite::params::apache_dir}/ports.conf",
          require => File["${::graphite::params::apache_dir}/ports.conf"],
          notify  => Service[$graphite::params::apache_service_name];
        }
      }
    }
    default: {}
  }
}
