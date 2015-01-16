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

  $nginxconf_dir                   = '/etc/nginx/sites-available'
  $install_dir                     = '/opt/graphite'
  $storage_dir                     = '/opt/graphite/storage'
  $user                            = 'www-data'
  $group                           = 'www-data'
  $carbon_metric_interval          = 60
  $timezone                        = 'UTC'
  $enable_carbon_relay             = true
  $enable_carbon_cache             = true
  $enable_carbon_aggregator        = false
  $enable_webapp                   = true
  $use_packages                    = true
  $memcache_hosts                  = ['127.0.0.1']
  $memcache_port                   = 11211

  $amqp_enable                      = False
  $amqp_verbose                     = False
  $amqp_host                        = 'localhost'
  $amqp_port                        = 5672
  $amqp_vhost                       = '/'
  $amqp_user                        = 'guest'
  $amqp_password                    = 'guest'
  $amqp_exchange                    = 'graphite'
  $amqp_metric_name_in_body         = False

  $cache_user                     = 'www-data'
  $cache_enable_logrotation       = False
  $cache_log_listener_connections = True
  $cache_use_flow_control         = True
  $cache_log_updates              = False
  $cache_log_cache_hits           = False
  $cache_log_cache_queue_sorts    = True
  $cache_whisper_autoflush        = False
  $cache_whisper_fallocate_create = True
  $cache_whisper_sparse_create    = True
  $cache_max_cache_size           = inf
  $cache_max_updates_per_second   = 50000
  $cache_max_creates_per_minute   = 50000

  $cache_line_receiver_interface   = $::ipaddress
  $cache_line_receiver_port        = 2003
  $cache_enable_udp_listener       = false
  $cache_udp_receiver_interface    = $::ipaddress
  $cache_udp_receiver_port         = 2003
  $cache_pickle_receiver_interface = $::ipaddress
  $cache_pickle_receiver_port      = 2004
  $cache_write_strategy            = 'naive'
  $cache_use_insecure_unpickler    = false
  $cache_use_whitelist             = false
  $cache_query_interface           = $::ipaddress
  $cache_query_port                = 7002
  $cache_count                     = 1

  $relay_line_receiver_interface         = $::ipaddress
  $relay_line_receiver_port              = 2003
  $relay_pickle_receiver_interface       = $::ipaddress
  $relay_pickle_receiver_port            = 2004
  $relay_destinations                    = []
  $relay_enable_logrotation              = false
  $relay_log_listener_connections        = true
  $relay_relay_method                    = 'consistent-hashing'
  $relay_replication_factor              = 1
  $relay_max_datapoints_per_message      = 500
  $relay_max_queue_size                  = 5000000
  $relay_use_flow_control                = true
  $relay_use_whitelist                   = false
  $relay_to_cache                        = false
  $relay_cache_count                     = 1
  $relay_carbon_metric_interval          = 60

  $aggregator_line_receiver_interface    = '0.0.0.0'
  $aggregator_line_receiver_port         = 2023
  $aggregator_pickle_receiver_interface  = '0.0.0.0'
  $aggregator_pickle_receiver_port       = 2024
  $aggregator_log_listener_connections   = true
  $aggregator_forward_all                = true
  $aggregator_destinations               = [ '127.0.0.1:2004' ]
  $aggregator_replication_factor         = 1
  $aggregator_max_queue_size             = 10000
  $aggregator_use_flow_control           = true
  $aggregator_max_datapoints_per_message = 500
  $aggregator_max_aggregation_intervals  = 5
  $aggregator_write_back_frequency       = 0
  $aggregator_use_whitelist              = false
  $aggregator_carbon_metric_prefix       = 'carbon'
  $aggregator_carbon_metric_interval     = 60

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
  $web_server_package_require     = undef
  $web_server                     = 'apache'
  $web_servername                 = $::fqdn
  $web_cors_allow_from_all        = true
  $web_server_port                = 80
  $use_remote_user_auth           = false
  $use_ldap                       = false
  $storage_schemas           = {
    'carbon' => {
      pattern    => '^carbon\.',
      retentions => '1m:90d'
    },
    'default' => {
      pattern    => '.*',
      retentions => '1s:30m,1m:1d,5m:2y'
    }
  }

  $blacklist = {}

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
      factor => '0.0',
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

  
    $apache_pkg = 'apache2'
    $apache_wsgi_pkg = 'libapache2-mod-wsgi'
    $apache_wsgi_socket_prefix = '/var/run/apache2/wsgi'
    $apache_service_name = 'apache2'
    $apacheconf_dir = '/etc/apache2/sites-available'
    $apacheports_file = 'ports.conf'
    $apache_dir = '/etc/apache2'
    $web_user = 'www-data'
    $python_dev_pkg = 'python-dev'

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
    

  $web_server_pkg = $graphite::params::web_server ? {
    apache   => $apache_pkg,
    nginx    => 'nginx',
    wsgionly => 'dont-install-webserver-package',
    none     => 'dont-install-webserver-package',
    default  => fail('The only supported web servers are \'apache\', \'nginx\',  \'wsgionly\' and \'none\''),
  }

}
