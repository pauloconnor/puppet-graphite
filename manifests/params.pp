# == Class: graphite::params
#
# This class specifies default parameters for the graphite module and
# SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::params {
  $build_dir                       = '/usr/local/src'

  $python_pip_pkg                  = 'python-pip'
  $django_tagging_ver              = '0.3.1'
  $twisted_ver                     = '11.1.0'
  $txamqp_ver                      = '0.4'
  $graphiteVersion                 = '0.9.12'
  $carbonVersion                   = '0.9.12'
  $whisperVersion                  = '0.9.12'

  $whisper_dl_url                  = "http://github.com/graphite-project/whisper/archive/${::graphite::params::whisperVersion}.tar.gz"
  $whisper_dl_loc                  = "${build_dir}/whisper-${::graphite::params::whisperVersion}.tar.gz"

  $webapp_dl_url                   = "http://github.com/graphite-project/graphite-web/archive/${::graphite::params::graphiteVersion}.tar.gz"
  $webapp_dl_loc                   = "${build_dir}/graphite-web-${::graphite::params::graphiteVersion}.tar.gz"

  $carbon_dl_url                   = "https://github.com/graphite-project/carbon/archive/${::graphite::params::carbonVersion}.tar.gz"
  $carbon_dl_loc                   = "${build_dir}/carbon-${::graphite::params::carbonVersion}.tar.gz"

  $nginxconf_dir                   = '/etc/nginx/sites-available'
  $install_dir                      = $graphite::install_dir
  $user                            = 'root'
  $group                           = 'root'
  $max_cache_size                  = 500000
  $max_updates_per_second          = 500000
  $max_creates_per_minute          = 50000
  $carbon_metric_interval          = 60
  $timezone                        = 'UTC'
  $enable_carbon_relay             = true
  $enable_carbon_cache             = true
  $enable_webapp                   = true
  $use_packages                    = true
  $memcache_hosts                  = undef

  $amqp_enable                      = False
  $amqp_verbose                     = False
  $amqp_host                        = 'localhost'
  $amqp_port                        = 5672
  $amqp_vhost                       = '/'
  $amqp_user                        = 'guest'
  $amqp_password                    = 'guest'
  $amqp_exchange                    = 'graphite'
  $amqp_metric_name_in_body         = False

  $cache_line_receiver_interface   = '0.0.0.0'
  $cache_line_receiver_port        = 2003
  $cache_enable_udp_listener       = false
  $cache_udp_receiver_interface    = '0.0.0.0'
  $cache_udp_receiver_port         = 2003
  $cache_pickle_receiver_interface = '0.0.0.0'
  $cache_pickle_receiver_port      = 2004
  $cache_write_strategy            = 'naive'
  $cache_use_insecure_unpickler    = false
  $cache_use_whitelist             = false
  $cache_query_interface           = '0.0.0.0'
  $cache_query_port                = 7002
  $cache_count                     = 1

  $relay_line_receiver_interface         = '0.0.0.0'
  $relay_line_receiver_port              = 2003
  $relay_pickle_receiver_interface       = '0.0.0.0'
  $relay_pickle_receiver_port            = 2004
  $relay_destinations                    = []
  $relay_relay_method                    = 'consistent-hashing'
  $relay_replication_factor              = 1
  $relay_max_datapoints_per_message      = 500
  $relay_max_queue_size                  = 500000
  $relay_use_flow_control                = true
  $relay_use_whitelist                   = false
  $relay_to_cache                        = false
  $relay_cache_count                     = 1
  $relay_carbon_metric_interval          = 60

  $django_1_4_or_less             = false
  $django_db_engine               = 'django.db.backends.sqlite3'
  $django_db_name                 = 'graphite.db'
  $django_db_user                 = ''
  $django_db_password             = ''
  $django_db_host                 = ''
  $django_db_port                 = ''
  $webapp_cluster_enable          = false
  $webapp_cluster_servers         = '[]'
  $webapp_cluster_fetch_timeout   = 6
  $webapp_cluster_find_timeout    = 2.5
  $webapp_cluster_retry_delay     = 60
  $webapp_cluster_cache_duration  = 300
  $webapp_memcache_hosts          = undef
  $webapp_secret_key              = 'UNSAFE_DEFAULT'
  $webapp_nginx_htpasswd          = undef
  $webapp_manage_ca_certificate   = true
  $webapp_use_remote_user_auth    = 'False'
  $webapp_remote_user_header_name = undef
  $web_server                     = 'apache'
  $web_servername                 = $::fqdn
  $web_cors_allow_from_all        = true
  $web_server_port                = 80
  $use_remote_user_auth           = false

  $storage_schemas           = [
    {
      name       => 'carbon',
      pattern    => '^carbon\.',
      retentions => '1m:90d'
    },
    {
      name       => 'default',
      pattern    => '.*',
      retentions => '1s:30m,1m:1d,5m:2y'
    }
  ]

  $storage_aggregation_rules  = {
    '00_min' => {
      pattern => '\.min$',
      factor => '0.1',
      method => 'min'
    },
    '01_max' => {
      pattern => '\.max$',
      factor => '0.1',
      method => 'max'
    },
    '02_sum' => {
      pattern => '\.count$',
      factor => '0.1',
      method => 'sum'
    },
    '99_default_avg' => {
      pattern => '.*',
      factor => '0.5',
      method => 'average'
    }
  }

  $relay_rules               = {
    all => {
      pattern      => '.*',
      destinations => [ '127.0.0.1:2014' ]
    },
    'default' => {
      'default'    => true,
      destinations => [ '127.0.0.1:2014' ]
    }
  }

  $aggregator_rules           = {
    'carbon-class-mem' => 'carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
    'carbon-all-mem'   => 'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
  }

  $relays                     = { 0 => {
        line_receiver_interface    => '127.0.0.1',
        line_receiver_port         => '2003',
        pickle_receiver_interface  => '127.0.0.1',
        pickle_receiver_port       => '2004',
        destinations               => [ '127.0.0.1:2014' ],
        relay_method               => 'rules',
        replication_factor         => 1,
        max_datapoints_per_message => 500,
        max_queue_size             => 3000,
        use_flow_control           => true,
        use_whitelist              => false,
        to_cache                   => true,
        cache_count                => 1,
      }
                                }

  $caches                     =  { 0 => {
        line_receiver_interface   => '127.0.0.1',
        line_receiver_port        => '2103',
        enable_udp_listener       => true,
        udp_receiver_interface    => '127.0.0.1',
        udp_receiver_port         => '2103',
        pickle_receiver_interface => '127.0.0.1',
        pickle_receiver_port      => '2104',
        cache_write_strategy      => 'naive',
        use_insecure_unpickler    => false,
        use_whitelist             => false,
        query_interface           => '127.0.0.1',
        query_port                => '7104',
        count                     => 1
      },
                                }

  case $::osfamily {
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
#        'python-mysqldb',
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
      case $::operatingsystemrelease {
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

  $web_server_pkg = $graphite::params::web_server ? {
    apache   => $apache_pkg,
    nginx    => 'nginx',
    wsgionly => 'dont-install-webserver-package',
    none     => 'dont-install-webserver-package',
    default  => fail('The only supported web servers are \'apache\', \'nginx\',  \'wsgionly\' and \'none\''),
  }

}
