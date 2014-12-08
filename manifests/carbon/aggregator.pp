# Define graphite::carbon::aggregator
# Configure Aggregator
define graphite::carbon::aggregator (
  $line_receiver_interface    =   $graphite::params::aggregator_line_receiver_interface,
  $line_receiver_port         =   $graphite::params::aggregator_line_receiver_port,
  $pickle_receiver_interface  =   $graphite::params::aggregator_pickle_receiver_interface,
  $pickle_receiver_port       =   $graphite::params::aggregator_pickle_receiver_port,
  $log_listener_connections   =   $graphite::params::aggregator_log_listener_connections,
  $enable_logrotation         =   $graphite::params::aggregator_enable_logrotation,
  $forward_all                =   $graphite::params::aggregator_forward_all,
  $destinations               =   $graphite::params::aggregator_destinations,
  $replication_factor         =   $graphite::params::aggregator_replication_factor,
  $max_queue_size             =   $graphite::params::aggregator_max_queue_size,
  $use_flow_control           =   $graphite::params::aggregator_use_flow_control,
  $max_datapoints_per_message =   $graphite::params::aggregator_max_datapoints_per_message,
  $max_aggregation_intervals  =   $graphite::params::aggregator_max_aggregation_intervals,
  $write_back_frequency       =   $graphite::params::aggregator_write_back_frequency,
  $use_whitelist              =   $graphite::params::aggregator_use_whitelist,
  $carbon_metric_prefix       =   $graphite::params::aggregator_carbon_metric_prefix,
  $carbon_metric_interval     =   $graphite::params::aggregator_carbon_metric_interval
  ) {

  # 'carbon-class-mem' => 'carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
  #  'carbon-all-mem'   => 'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
  #  }
  # INSTALL AGGREGATORS!   


  # conf cache
  if !is_ip_address($line_receiver_interface) {
    fail("\$line_receiver_interface must be an IPv4 address - ${line_receiver_interface}")
  }
  if !is_numeric($line_receiver_port) {
    fail ('$line_receiver_port must be an integer')
  }
  if !is_ip_address($pickle_receiver_interface) {
    fail("\$pickle_receiver_interface must be an IPv4 address - ${pickle_receiver_interface}")
  }
  if !is_numeric($pickle_receiver_port) {
    fail('$pickle_receiver_port must be an integer')
  }
  validate_bool($log_listener_connections)
  validate_bool($forward_all)
  validate_array($destinations)
  validate_bool($use_whitelist)
  if !is_numeric($replication_factor) {
    fail('$replication_factor must be an integer')
  }
  if !is_numeric($max_queue_size) {
    fail('$max_queue_size must be an integer')
  }
  validate_bool($use_flow_control)
  if !is_numeric($max_datapoints_per_message) {
    fail('$max_datapoints_per_message must be an integer')
  }
  if !is_numeric($max_aggregation_intervals) {
    fail('$max_aggregation_intervals must be an integer')
  }
  if !is_numeric($write_back_frequency) {
    fail('$write_back_frequency must be an integer')
  }
  validate_bool($use_whitelist)
  
  if !is_numeric($carbon_metric_interval) {
    fail('$carbon_metric_interval must be an integer')
  }

  concat::fragment { "conf/carbon.conf-aggregator-${title}":
    target  => "${graphite::install_dir}/conf/carbon.conf",
    content => template('graphite/opt/graphite/conf/carbon/aggregator.erb'),
    order   => '35',
  }
}