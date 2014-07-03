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
  include graphite::webserver::nginx
  #$web_server_package_require = [Package["${::graphite::params::web_server_pkg}"]]

  # first init of user db for graphite

  exec { 'Initial django db creation':
    command     => 'python manage.py syncdb --noinput',
    cwd         => "${graphite::install_dir}/webapp/graphite",
    refreshonly => true,
    subscribe   => Class['graphite::install'],
    require     => File["${graphite::install_dir}/webapp/graphite/local_settings.py"];
  }~>

  # change access permissions for web server

  exec { 'Chown graphite for web user':
    command     => "/bin/chown -R ${graphite::params::web_user}:${graphite::params::web_user} ${graphite::install_dir}",
    cwd         => "${graphite::install_dir}/",
    refreshonly => true,
    require     => $web_server_package_require,
  }

  # change access permissions for carbon-cache to align with gr_user
  # (if different from web_user)

  if $graphite::user != '' and $graphite::group != '' and $graphite::user != $graphite::params::web_user {
    file {
      "${graphite::storage_dir}/whisper":
        ensure  => directory,
        owner   => $graphite::params::web_user,
        group   => $graphite::group,
        mode    => '0755',
        require => Exec['Chown graphite for web user'];
      "${graphite::storage_dir}/log/carbon-cache":
        ensure  => directory,
        owner   => $graphite::params::web_user,
        group   => $graphite::group,
        mode    => '0755',
        require => Exec['Chown graphite for web user'];
    }
  }

  # Deploy configfiles

  file {
    "${graphite::install_dir}/webapp/graphite/local_settings.py":
      ensure  => file,
      owner   => $graphite::params::web_user,
      group   => $graphite::params::web_user,
      mode    => '0644',
      content => template('graphite/opt/graphite/webapp/graphite/local_settings.py.erb'),
      require => $web_server_package_require;
    "${graphite::install_dir}/conf/graphite.wsgi":
      ensure  => file,
      owner   => $graphite::params::web_user,
      group   => $graphite::params::web_user,
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/graphite.wsgi.erb'),
      require => $web_server_package_require;
  }

  if $::graphite::gr_remote_user_header_name != undef {
    file {
      "${graphite::install_dir}/webapp/graphite/custom_auth.py":
        ensure  => file,
        owner   => $::graphite::params::web_user,
        group   => $::graphite::params::web_user,
        mode    => '0644',
        content => template('graphite/opt/graphite/webapp/graphite/custom_auth.py.erb'),
        require => $web_server_package_require;
    }
  }


  # configure carbon engines
  if $graphite::enable_carbon_relay and $graphite::gr_enable_carbon_aggregator {
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
      notify  => $notify_services;
    "${graphite::install_dir}/conf/carbon.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/carbon.conf.erb'),
      notify  => $notify_services;
    "${graphite::install_dir}/conf/storage-aggregation.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/storage-aggregation.conf.erb'),
      notify  => $notify_services;
    "${graphite::install_dir}/conf/relay-rules.conf":
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
      notify  => $notify_services;
  }

  logrotate::rule { 'carbon_logs':
    path         => "${graphite::storage_dir}/logs/carbon-*",
    rotate       => 5,
    rotate_every => 'day',
  }

  logrotate::rule { 'webapp_logs':
    path          => "${graphite::storage_dir}/logs/webapp",
    rotate        => 5,
    rotate_every  => 'day',
  }

  # startup carbon engine

  service { 'carbon-cache':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/carbon-cache'];
  }

  file { '/etc/init.d/carbon-cache':
    ensure  => file,
    mode    => '0750',
    content => template('graphite/etc/init.d/carbon-cache.erb'),
    require => File["${graphite::install_dir}/conf/carbon.conf"];
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
      require => File["${graphite::install_dir}/conf/carbon.conf"];
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
      require => File["${graphite::install_dir}/conf/carbon.conf"];
    }
  }
}
