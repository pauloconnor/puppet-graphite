# relays = [ 
#      '09' =>
#      {
#        line_receiver_port         => '2193',
#        pickle_receiver_port       => '2194',
#        destinations               => [ "10.56.5.200:2294", "10.56.6.200:2294" ],
#        relay_method               => 'consistent-hashing',
#        replication_factor         => 2,
#        use_flow_control           => true,
#        use_whitelist              => false,
#        to_cache                   => false,
#      },
#      '10' =>
#      {
#        line_receiver_port         => '2203',
#        pickle_receiver_port       => '2204',
#        destinations               => [ "${::ipaddress}:2804" ],
#        relay_method               => 'consistent-hashing',
#        replication_factor         => 1,
#        use_flow_control           => true,
#        use_whitelist              => false,
#        to_cache                   => true,
#        cache_count                => $cache_count,
#      },
#
#   ]
#
define graphite::carbon::relay(
    $line_receiver_interface    = $graphite::params::relay_line_receiver_interface,
    $line_receiver_port         = $graphite::params::relay_line_receiver_port,
    $pickle_receiver_interface  = $graphite::params::relay_pickle_receiver_interface,
    $pickle_receiver_port       = $graphite::params::relay_pickle_receiver_port,
    $destinations               = [$graphite::params::relay_destinations],
    $relay_method               = $graphite::params::relay_relay_method,
    $replication_factor         = $graphite::params::relay_replication_factor,
    $max_datapoints_per_message = $graphite::params::relay_max_datapoints_per_message,
    $max_queue_size             = $graphite::params::relay_max_queue_size,
    $use_flow_control           = $graphite::params::relay_use_flow_control,
    $use_whitelist              = $graphite::params::relay_use_whitelist,
    $to_cache                   = $graphite::params::relay_to_cache,
    $cache_count                = $graphite::params::relay_cache_count,
    $port_modifier              = true,
    $port_addition              = 0,
  ) {

  if !is_ip_address($line_receiver_interface) {
    fail('Please enter a proper IPv4 address')
  }
  if !is_numeric($line_receiver_port) {
    fail ('$line_receiver_port must be an integer')
  }
  if !is_ip_address($pickle_receiver_interface) {
    fail('Please enter a proper IPv4 address')
  }
  if !is_numeric($pickle_receiver_port) {
    fail('$pickle_receiver_port must be an integer')
  }
  validate_array($destinations)
  validate_re($relay_method, '^(relay-rules|consistent-hashing)$')
  if !is_numeric($replication_factor){
    fail('$replication_factor must be an integer')
  }
  if !is_numeric($max_datapoints_per_message) {
    fail('$max_datapoints_per_message must be an integer')
  }
  if !is_numeric($max_queue_size) {
    fail('$max_queue_size must be an integer')
  }
  if !is_numeric($cache_count) {
    fail('$cache_count must be an integer')
  }

  validate_bool($use_flow_control)
  validate_bool($use_whitelist)
  validate_bool($to_cache)
  validate_boolean($port_modifier)

  if $port_modifier {
    $port_addition = $title * 10
  }

  concat::fragment { "${graphite::install_dir}/conf/carbon.conf":
    target  => "${::graphite::params::install_dir}/conf/carbon.conf",
    content => template('graphite/conf/carbon/relay.erb'),
    order   => '25',
  }
}