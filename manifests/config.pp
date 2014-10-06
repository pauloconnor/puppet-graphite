# == Class: graphite::config
#
# This class configures graphite/carbon/whisper and SHOULD NOT
# be called directly.
#
# === Parameters
#
# None.
#
class graphite::config inherits graphite::params {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  # for full functionality we need this packages:
  # mandatory: python-cairo, python-django, python-twisted,
  #            python-django-tagging, python-simplejson
  # optional:  python-ldap, python-memcache, memcached, python-sqlite

  # we need an web server with python support
  # apache with mod_wsgi or nginx with gunicorn
  #include graphite::webserver::nginx
  #include graphite::webserver::apache
  #$web_server_package_require = [Package["${::graphite::params::web_server_pkg}"]]

  # change access permissions for web server

#  exec { 'Chown graphite for web user':
#    command     => "/bin/chown -R ${graphite::user}:${graphite::group} ${graphite::install_dir}",
#    cwd         => "${graphite::install_dir}/",
#    refreshonly => true,
#    require     => $web_server_package_require,
#  }->
#  exec { 'Chown graphite storage for web user':
#    command     => "/bin/chown -R ${graphite::user}:${graphite::group} ${graphite::storage_dir}",
#    cwd         => "${graphite::storage_dir}/",
#    refreshonly => true,
#    require     => $web_server_package_require,
#  }

  exec { 'Initial django db creation':
    creates     => "${graphite::storage_dir}/graphite.db",
    command     => '/usr/bin/python manage.py syncdb --noinput',
    cwd         => "${graphite::install_dir}/webapp/graphite",
    require     => File["${graphite::install_dir}/webapp/graphite/local_settings.py"],
  }->
  exec { 'Set db owner':
    command     => "/bin/chown -R ${graphite::user}:${graphite::group} ${graphite::storage_dir}/graphite.db",
    cwd         => "${graphite::storage_dir}/",
    refreshonly => true,
  }

  # change access permissions for carbon-cache to align with gr_user
  # (if different from web_user)

  file { [
    $graphite::storage_dir,
    "${graphite::storage_dir}/whisper",
    "${graphite::storage_dir}/rrd",
    "${graphite::storage_dir}/log",
    "${graphite::storage_dir}/log/carbon-cache",
    "${graphite::storage_dir}/log/webapp" ]:
      ensure  => directory,
      owner   => $graphite::user,
      group   => $graphite::group,
      mode    => '0755';
  }

    file { "${graphite::storage_dir}/index":
      ensure  => file,
      owner   => $graphite::user,
      group   => $graphite::group,
      mode    => '0755';
  }

  # Deploy configfiles

  file {
    "${graphite::install_dir}/webapp/graphite/local_settings.py":
      ensure  => file,
      owner   => $graphite::user,
      group   => $graphite::group,
      mode    => '0644',
      content => template('graphite/opt/graphite/webapp/graphite/local_settings.py.erb');
    "${graphite::install_dir}/conf/graphite.wsgi":
      ensure  => file,
      owner   => $graphite::user,
      group   => $graphite::group,
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/graphite.wsgi.erb');
  }

  if $graphite::webapp_remote_user_header_name != undef {
    file {
      "${graphite::install_dir}/webapp/graphite/custom_auth.py":
        ensure  => file,
        owner   => $graphite::user,
        group   => $graphite::group,
        mode    => '0644',
        content => template('graphite/opt/graphite/webapp/graphite/custom_auth.py.erb'),
        require => $graphite::web_server_package_require;
    }
  }


  # configure carbon engines
  if $graphite::enable_carbon_relay and $graphite::enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-relay'],
      Service['carbon-cache']
    ]
  }
  elsif $graphite::enable_carbon_relay {
    $notify_services = [
      Service['carbon-relay'],
      Service['carbon-cache']
    ]
  }
  elsif $graphite::enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-cache']
    ]
  }
  else {
    $notify_services = [ Service['carbon-cache'] ]
  }

  if $graphite::enable_carbon_aggregator {
    file {
      "${graphite::install_dir}/conf/aggregation-rules.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/aggregation-rules.conf.erb'),
      notify  => $notify_services;
    }
  }

  file {
    "${graphite::install_dir}/conf/storage-schemas.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/storage-schemas.conf.erb'),
      require => File["${graphite::install_dir}/webapp/graphite/local_settings.py"];
    "${graphite::install_dir}/conf/storage-aggregation.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/storage-aggregation.conf.erb'),
      notify  => $notify_services,
      require => File["${graphite::install_dir}/webapp/graphite/local_settings.py"];
    "${graphite::install_dir}/conf/relay-rules.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
      notify  => $notify_services,
      require => File["${graphite::install_dir}/webapp/graphite/local_settings.py"];
  }

  concat { "${graphite::install_dir}/conf/carbon.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $notify_services
  }

  concat::fragment { '01-graphite-header':
    target  => "${graphite::install_dir}/conf/carbon.conf",
    order   => '01',
    content => "# This file managed by Puppet\n",
  }

  # Template uses $global_options, $defaults_options
  concat::fragment { '02-cache-head':
    target  => "${graphite::install_dir}/conf/carbon.conf",
    order   => '02',
    content => template('graphite/opt/graphite/conf/carbon/cache-head.conf.erb'),
  }

  # Template uses $global_options, $defaults_options
  concat::fragment { '20-relay-head':
    target  => "${graphite::install_dir}/conf/carbon.conf",
    order   => '20',
    content => template('graphite/opt/graphite/conf/carbon/relay-head.conf.erb'),
  }

  if $graphite::enable_carbon_aggregator {
    # Template uses $global_options, $defaults_options
    concat::fragment { '30-aggregator-head':
      target  => "${graphite::install_dir}/conf/carbon.conf",
      order   => '30',
      content => template('graphite/opt/graphite/conf/carbon/aggregator-head.conf.erb'),
    }
  }

  logrotate::rule { 'carbon_logs':
    path         => "${graphite::storage_dir}/log/carbon-*",
    rotate       => 5,
    rotate_every => 'day',
  }

  logrotate::rule { 'webapp_logs':
    path          => "${graphite::storage_dir}/log/webapp",
    rotate        => 5,
    rotate_every  => 'day',
  }

  
  file { '/etc/init.d/carbon-cache':
    ensure  => file,
    mode    => '0750',
    content => template('graphite/etc/init.d/carbon-cache.erb'),
    require => Concat["${graphite::install_dir}/conf/carbon.conf"];
  }

  # startup carbon engine

  service { 'carbon-cache':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/carbon-cache'];
  }

  if $graphite::enable_carbon_relay {
    service { 'carbon-relay':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File['/etc/init.d/carbon-relay'];
    }

    file { '/etc/init.d/carbon-relay':
      ensure  => file,
      mode    => '0750',
      content => template('graphite/etc/init.d/carbon-relay.erb'),
      require => Concat["${graphite::install_dir}/conf/carbon.conf"];
    }
  }

  if $graphite::enable_carbon_aggregator {
    service {'carbon-aggregator':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File['/etc/init.d/carbon-aggregator'];
    }

    file { '/etc/init.d/carbon-aggregator':
      ensure  => file,
      mode    => '0750',
      content => template('graphite/etc/init.d/carbon-aggregator.erb'),
      require => Concat["${graphite::install_dir}/conf/carbon.conf"];
    }
  }
}
