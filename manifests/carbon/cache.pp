define graphite::carbon::cache (
  $line_receiver_interface   = $graphite::params::cache_line_receiver_interface,
  $line_receiver_port        = $graphite::params::cache_line_receiver_port,
  $enable_udp_listener       = $graphite::params::cache_enable_udp_listener,
  $udp_receiver_interface    = $graphite::params::cache_udp_receiver_interface,
  $udp_receiver_port         = $graphite::params::cache_udp_receiver_port,
  $pickle_receiver_interface = $graphite::params::cache_pickle_receiver_interface,
  $pickle_receiver_port      = $graphite::params::cache_pickle_receiver_port,
  $cache_write_strategy      = $graphite::params::cache_cache_write_strategy,
  $use_insecure_unpickler    = $graphite::params::cache_use_insecure_unpickler,
  $use_whitelist             = $graphite::params::cache_use_whitelist,
  $query_interface           = $graphite::params::cache_query_interface,
  $query_port                = $graphite::params::cache_query_port,
  $cache_count               = $graphite::params::cache_count
  ) {

  # conf cache
  if !is_ip_address($line_receiver_interface) {
    fail("$line_receiver_interface must be an IPv4 address - ${line_receiver_interface}")
  }
  if !is_numeric($line_receiver_port) {
    fail ('$line_receiver_port must be an integer')
  }
  validate_bool($enable_udp_listener)
  if !is_ip_address($udp_receiver_interface) {
    fail("$udp_receiver_interface must be an IPv4 address - ${udp_receiver_interface}")
  }
  if !is_numeric($udp_receiver_port) {
    fail('$udp_receiver_port must be an integer')
  }
  validate_re($cache_write_strategy, '^(max|sorted|naive)$',
              'Please chose Max, Sorted or Naive for Write Strategy')
  validate_bool($use_insecure_unpickler)
  validate_bool($use_whitelist)
  if !is_ip_address($pickle_receiver_interface) {
    fail('$pickle_receiver_interface must be an IPv4 address')
  }
  if !is_numeric($pickle_receiver_port) {
    fail('$pickle_receiver_port must be an integer')
  }
  if !is_ip_address($query_interface) {
    fail("$query_interface must be an IPv4 address - ${query_interface}")
  }
  if !is_numeric($query_port) {
    fail('$query_port must be an integer')
  }
  if !is_numeric($cache_count) {
    fail('$cache_count must be an integer')
  }

  concat::fragment { "conf/carbon.conf-cache-${title}":
    target  => "${graphite::install_dir}/conf/carbon.conf",
    content => template('graphite/opt/graphite/conf/carbon/cache.erb'),
    order   => '15',
  }
}