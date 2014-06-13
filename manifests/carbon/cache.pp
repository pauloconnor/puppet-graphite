define graphite::cache (
  $line_receiver_interface   = '0.0.0.0',
  $line_receiver_port        = 2003,
  $enable_udp_listener       = 'False',
  $udp_receiver_interface    = '0.0.0.0',
  $udp_receiver_port         = 2003,
  $pickle_receiver_interface = '0.0.0.0',
  $pickle_receiver_port      = 2004,
  $cache_write_strategy      = 'sorted',
  $use_insecure_unpickler    = 'False',
  $use_whitelist             = 'False',
  $cache_query_interface     = '0.0.0.0',
  $cache_query_port          = 7002,
  $cache_count               = 1
  ) {

  # conf cache

  
}