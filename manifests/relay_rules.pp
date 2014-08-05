define relay_rule (
  $name,
  $pattern,
  $default      = 'false',
  $destinations = [] 
  ) {

  concat::fragment { "{$::graphite::install_dir}/conf/relay-rules.conf":
      mode    => '0644',
      ensure  => present,
      content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
  }
}