define graphite::relay(
    $line_receiver_interface    = '0.0.0.0',
    $line_receiver_port         = 2003,
    $pickle_receiver_interface  = '0.0.0.0',
    $pickle_receiver_port       = 2004,
    $destinations,
    $relay_method               = 'consistent-hashing',
    $replication_factor         = 1,
    $max_datapoints_per_message = 500,
    $max_queue_size             = 500000,
    $use_flow_control           = 'false',
    $use_whitelist              = 'false'
  ) {

  is_ip_address
  validate_string
  validate_bool

  if $::graphite::enable_carbon_relay {
    file {
      "{$::graphite::install_dir}/conf/relay-rules.conf":
        mode    => '0644',
        content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
        notify  => $notify_services;
    }
  }
}