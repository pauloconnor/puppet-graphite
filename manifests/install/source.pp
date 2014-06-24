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
        owner   => 'root',
        group   => 'root',
        mode    => 750,
  }

  wget::fetch { 'wget_whisper':
    source      => $::graphite::params::whisper_dl_url,
    destination => $::graphite::params::whisper_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::install_dir],
  }->
  exec { 'unpack_whisper':
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::whisper_dl_loc}",
  }->
  # carbon goes to the /usr/bin by default. No overrides possible
  exec { 'install_whisper':
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
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::webapp_dl_loc}",
  }->
  exec { 'install_graphite':
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
    cwd         => $graphite::build_dir,
    command     => "/bin/tar -xzvf ${::graphite::params::carbon_dl_loc}",
  }->
  exec { 'install_carbon':
    cwd         => "${graphite::build_dir}/carbon-${::graphite::params::carbonVersion}",
    command     => "/usr/bin/python setup.py install --prefix=${::graphite::install_dir} --install-lib=${::graphite::install_dir}/lib",
  }
}