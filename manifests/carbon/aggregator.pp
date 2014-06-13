define graphite::aggregator (
  $enable_carbon_aggregator  = false,
  $aggregator_line_interface = '0.0.0.0',
  $aggregator_line_port      = 2023,
  $aggregator_pickle_interface = '0.0.0.0',
  $aggregator_pickle_port    = 2024,
  $aggregator_forward_all    = 'True',
  $aggregator_destinations   = [ '127.0.0.1:2004' ],
  $aggregator_replication_factor = 1,
  $aggregator_max_queue_size = 10000,
  $aggregator_use_flow_control = 'True',
  $aggregator_max_intervals  = 5,
  $aggregator_rules          = { }
  ) {
 
  # 'carbon-class-mem' => 'carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
  #  'carbon-all-mem'   => 'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
  #  }
  # INSTALL AGGREGATORS!   
}