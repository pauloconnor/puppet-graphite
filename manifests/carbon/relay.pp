# relays = [ 
#     { 'front': 
#        $ip                         = '127.0.0.1',
#        $port                       = '2003',
#        $pickle_ip                  = '127.0.0.1',
#        $pickle_port                = '2004',
#        $destinations               = [ '127.0.0.1:2004', '10.0.0.20:2004'],
#        $relay_method               = 'rules',
#        $replication_factor         = 1,
#        $max_datapoints_per_message = 500
#        $max_queue_size             = 3000000,
#        $use_flow_control           = 'true',
#        $use_whitelist              = 'false',
#        $to_cache                   = 'false'
#     },
#     { 'back': 
#        $ip                         = '127.0.0.1',
#        $port                       = '2103',
#        $pickle_ip                  = '127.0.0.1',
#        $pickle_port                = '2104',
#        $destinations               = [ '127.0.0.1:2104' ],
#        $relay_method               = 'consistent-hashing',
#        $replication_factor         = 1,
#        $max_datapoints_per_message = 500
#        $max_queue_size             = 3000000,
#        $use_flow_control           = 'true',
#        $use_whitelist              = 'false',
#        $to_cache                   = 'true',
#        $cache_count                = 8
#     }
#
#   ]
#
define graphite::carbon::relay(
    $line_receiver_interface    = $graphite::params::relay_line_receiver_interface,
    $line_receiver_port         = $graphite::params::relay_line_receiver_port,
    $pickle_receiver_interface  = $graphite::params::relay_pickle_receiver_interface,
    $pickle_receiver_port       = $graphite::params::relay_pickle_receiver_port,
    $destinations               = $graphite::params::relay_destinations,
    $relay_method               = $graphite::params::relay_relay_method,
    $replication_factor         = $graphite::params::relay_replication_factor,
    $max_datapoints_per_message = $graphite::params::relay_max_datapoints_per_message,
    $max_queue_size             = $graphite::params::relay_max_queue_size,
    $use_flow_control           = $graphite::params::relay_use_flow_control,
    $use_whitelist              = $graphite::params::relay_use_whitelist,
    $to_cache                   = $graphite::params::relay_to_cache,
    $cache_count                = $graphite::params::relay_cache_count,
  ) {

  #is_ip_address
  #validate_string
  #validate_bool


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

#  concat::fragment { 'carbon-conf':
#    target  => "#{graphite::params::install_dir}/conf/carbon.conf",
#    content => template('graphite/opt/graphite/conf/_relay.conf.erb'),
#    order   => '010',
#  }
}