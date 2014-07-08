# == Class: graphite::install::source
#
# This class installs graphite packages via source
#
# === Parameters
#
# None.
# 
class graphite::install::source inherits graphite::params { 

  file { [$graphite::install_dir,
          #$graphite::params::whisper_dl_loc,
          #$graphite::params::carbon_dl_loc,
          #$graphite::params::webapp_dl_loc
        ]:
        ensure  => directory,
        owner   => 'www-data',
        group   => 'www-data',
        mode    => 755,
  }

  wget::fetch { 'wget_whisper':
    source      => $::graphite::params::whisper_dl_url,
    destination => $::graphite::params::whisper_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::install_dir],
  }->
  exec { 'unpack_whisper':
    creates     => $graphite::params::whisper_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::whisper_dl_loc}",
  }->
  # whisper goes to the /usr/bin by default. No overrides possible
  exec { 'install_whisper':
    creates     => '/usr/local/bin/whisper-info.py',
    cwd         => "${graphite::build_dir}/whisper-${::graphite::params::whisperVersion}",
    command     => "/usr/bin/python setup.py install",
  }

  wget::fetch { 'wget_graphite':
    source      => $graphite::params::webapp_dl_url,
    destination => $graphite::params::webapp_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$graphite::install_dir],
  }->
  exec { 'unpack_graphite':
    creates     => $graphite::params::webapp_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::webapp_dl_loc}",
  }->
  exec { 'install_graphite':
    creates     => "${graphite::install_dir}/webapp",
    cwd         => "${graphite::build_dir}/graphite-web-${::graphite::params::graphiteVersion}",
    command     => "/usr/bin/python setup.py install --prefix=${graphite::install_dir} --install-lib=${graphite::install_dir}/webapp",
  }

  wget::fetch { 'wget_carbon':
    source      => $::graphite::params::carbon_dl_url,
    destination => $::graphite::params::carbon_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::install_dir],
  }->
  exec { 'unpack_carbon':
    creates     => $graphite::params::carbon_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::carbon_dl_loc}",
  }->
  exec { 'install_carbon':
    creates     => "${::graphite::install_dir}/lib",
    cwd         => "${graphite::build_dir}/carbon-${::graphite::params::carbonVersion}",
    command     => "/usr/bin/python setup.py install --prefix=${::graphite::install_dir} --install-lib=${::graphite::install_dir}/lib",
  }

  file { [
      "${graphite::install_dir}/bin",
      "${graphite::install_dir}/conf",
      "${graphite::install_dir}/examples",
      "${graphite::install_dir}/lib",
      "${graphite::install_dir}/storage",
      "${graphite::install_dir}/webapp",
      ]:
    ensure    => directory,
    owner     => 'www-data',
    group     => 'www-data',
  }

  exec { 'Initial django db creation':
    command     => 'python manage.py syncdb --noinput',
    cwd         => "${graphite::install_dir}/webapp/graphite",
    refreshonly => true,
    subscribe   => Exec['install_graphite'],
    require     => File["${graphite::install_dir}/webapp/graphite/local_settings.py"];
  }
}