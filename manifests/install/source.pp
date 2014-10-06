# == Class: graphite::install::source
#
# This class installs graphite packages via source
#
# === Parameters
#
# None.
# 
class graphite::install::source inherits graphite::params {

  $whisper_dl_url = "http://github.com/graphite-project/whisper/archive/${graphite::whisper_version}.tar.gz"
  $whisper_dl_loc = "${build_dir}/whisper-${graphite::whisper_version}.tar.gz"
  
  $webapp_dl_url  = "http://github.com/graphite-project/graphite-web/archive/${graphite::graphite_version}.tar.gz"
  $webapp_dl_loc  = "${build_dir}/graphite-web-${graphite::graphite_version}.tar.gz"
  
  $carbon_dl_url  = "https://github.com/graphite-project/carbon/archive/${graphite::carbon_version}.tar.gz"
  $carbon_dl_loc  = "${build_dir}/carbon-${graphite::carbon_version}.tar.gz"

  file { $graphite::install_dir:
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
  }

  file { $graphite::storage_dir:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
    before => [
      Exec['install_carbon'],
      Exec['install_graphite'],
    ]
  }

  wget::fetch { 'wget_whisper':
    source      => $whisper_dl_url,
    destination => $whisper_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::install_dir],
  }->
  exec { 'unpack_whisper':
    #creates     => $graphite::params::whisper_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${whisper_dl_loc}",
  }->
  # whisper goes to the /usr/bin by default. No overrides possible
  exec { 'install_whisper':
    #creates     => '/usr/local/bin/whisper-info.py',
    cwd         => "${graphite::build_dir}/whisper-${graphite::whisper_version}",
    command     => '/usr/bin/python setup.py install',
  }

  wget::fetch { 'wget_graphite':
    source      => $graphite::params::webapp_dl_url,
    destination => $graphite::params::webapp_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$graphite::install_dir],
  }->
  exec { 'unpack_graphite':
    #creates     => $graphite::params::webapp_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${webapp_dl_loc}",
  }->
  exec { 'install_graphite':
    #creates     => "${graphite::install_dir}/webapp",
    cwd         => "${graphite::build_dir}/graphite-web-${graphite::graphite_version}",
    command     => "/usr/bin/python setup.py install --prefix=${graphite::install_dir} --install-lib=${graphite::install_dir}/webapp",
  }

  wget::fetch { 'wget_carbon':
    source      => $carbon_dl_url,
    destination => $carbon_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::install_dir],
  }->
  exec { 'unpack_carbon':
    #creates     => $graphite::params::carbon_dl_loc,
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${carbon_dl_loc}",
  }->
  exec { 'install_carbon':
    #creates     => "${::graphite::install_dir}/lib",
    cwd         => "${graphite::build_dir}/carbon-${graphite::carbon_version}",
    command     => "/usr/bin/python setup.py install --prefix=${::graphite::install_dir} --install-lib=${::graphite::install_dir}/lib",
  }

  file { [
      "${graphite::install_dir}/bin",
      "${graphite::install_dir}/conf",
      "${graphite::install_dir}/examples",
      "${graphite::install_dir}/lib",
      "${graphite::install_dir}/webapp",
      "${graphite::storage_dir}/log",
      "${graphite::storage_dir}/log/webapp",
      ]:
    ensure     => directory,
    owner      => 'www-data',
    group      => 'www-data',
    recurse    => true,
  }

  exec { 'set_storage_permissions':
    command => "/bin/chown -R www-data:www-data ${graphite::storage_dir}",
    require => Exec['install_carbon'],
  }
}