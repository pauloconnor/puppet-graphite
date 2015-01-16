# == Class: graphite
#
# This class installs and configures graphite/carbon/whisper.
#
# 12 bytes per data point
#
# === Parameters
#
# === Examples
#
# class {'graphite':
#   gr_max_cache_size      => 256,
#   gr_enable_udp_listener => True,
#   gr_timezone            => 'Europe/Berlin'
# }
#
class graphite (
  $user                           = $graphite::params::user,
  $group                          = $graphite::params::group,
  $carbon_metric_interval         = $graphite::params::carbon_metric_interval,
  $timezone                       = $graphite::params::timezone,
  $enable_carbon_cache            = $graphite::params::enable_carbon_cache,
  $enable_carbon_relay            = $graphite::params::enable_carbon_relay,
  $enable_carbon_aggregator       = $graphite::params::enable_carbon_aggregator,
  $enable_webapp                  = $graphite::params::enable_webapp,
  $graphite_version               = '0.9.12',
  $carbon_version                 = '0.9.12',
  $whisper_version                = '0.9.12',
  $web_server                     = $graphite::params::web_server,
  $nginx_htpasswd                 = undef,
  $webapp_secret_key              = $graphite::params::webapp_secret_key,
  $use_packages                   = $graphite::params::use_packages,
  $memcache_hosts                 = $graphite::params::memcache_hosts,
  $memcache_port                  = $graphite::params::memcache_port,
  $storage_schemas                = $graphite::params::storage_schemas,
  $storage_aggregation_rules      = $graphite::params::storage_aggregation_rules,
  $aggregator_rules               = $graphite::params::aggregator_rules,
  $blacklist                      = $graphite::params::blacklist,
  $relay_rules                    = $graphite::params::relay_rules,
  $relays                         = $graphite::params::relays,
  $caches                         = $graphite::params::caches,
  $install_dir                    = $graphite::params::install_dir,
  $storage_dir                    = $graphite::params::storage_dir,
  $additional_servers             = '',
  $web_cors_allow_from_all        = true,
  $webapp_cluster_fetch_timeout   = 10,
  $webapp_cluster_find_timeout    = 10,
  $webapp_cluster_retry_delay     = 60,
  $webapp_cluster_cache_duration  = 60,
  $webapp_remote_user_header_name = $graphite::params::webapp_remote_user_header_name,
  $django_1_4_or_less             = $graphite::params::django_1_4_or_less,
  $use_remote_user_auth           = $graphite::params::use_remote_user_auth,
  $relay_list                     = [ 00],
  $relay_destinations             = ['127.0.0.1:2003'],
  $cache_count                    = 1,
  $query_port                     = 7002,
  $web_server_package_require     = $graphite::params::web_server_package_require,
  $use_ldap                       = $graphite::params::use_ldap,
) inherits graphite::params {
  # Validation of input variables.
  # TODO - validate all the things
  validate_string($user)
  validate_string($carbon_metric_interval)
  validate_string($timezone)
  validate_bool($enable_carbon_cache)
  validate_bool($enable_carbon_relay)
  validate_bool($enable_webapp)
  validate_re($web_server, '^(apache|nginx|wsgionly|none)$')
  validate_string($install_dir)
  validate_bool($use_packages)

  class { 'graphite::install':}->
  class { 'graphite::config':}

}
