# == Class: graphite::install::source
#
# This class installs graphite packages via source
#
# === Parameters
#
# None.
# 
class graphite::install::source inherits graphite::params { 

  file { [$::graphite::params::whisper_dl_loc,
          $::graphite::params::carbon_dl_loc,
          $::graphite::params::webapp_dl_url
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
    require     => File[$::graphite::params::whisper_dl_loc],
  }->
  exec { 'unpack_whisper':
    cwd         => $::graphite::params::whisper_dl_loc,
    command     => "/bin/tar -xzvf ${::graphite::params::whisper_dl_loc}/${::graphite::params::whisperVersion}.tar.gz",
  }->
  # carbon goes to the /usr/bin by default. No overrides possible
  exec { 'install_whisper':
    cwd         => "${::graphite::params::whisper_dl_loc}/whisper-${::graphite::params::whisperVersion}",
    command     => "install /usr/local/bin/python setup.py",
  }

  wget::fetch { 'wget_webapp':
    source      => $::graphite::params::webapp_dl_url,
    destination => $::graphite::params::webapp_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::params::webapp_dl_loc],
  }->
  exec { 'unpack_webapp':
    cwd         => $::graphite::params::webapp_dl_loc,
    command     => "/bin/tar -xzvf ${::graphite::params::webapp_dl_loc}/${::graphite::params::webappVersion}.tar.gz",
  }->
  exec { 'install_webapp':
    cwd         => "${::graphite::params::webapp_dl_loc}/graphite-web-${::graphite::params::webappVersion}",
    command     => "install /usr/local/bin/python setup.py --prefix=${::graphite::install_dir} --install-lib=${::graphite::params::install_dir}/webapp",
  }

  wget::fetch { 'wget_carbon':
    source      => $::graphite::params::carbon_dl_url,
    destination => $::graphite::params::carbon_dl_loc,
    timeout     => 0,
    verbose     => false,
    require     => File[$::graphite::params::carbon_dl_loc],
  }->
  exec { 'unpack_carbon':
    cwd         => $::graphite::params::carbon_dl_loc,
    command     => "/bin/tar -xzvf ${::graphite::params::carbon_dl_loc}/${::graphite::params::carbonVersion}.tar.gz",
  }->
  exec { 'install_carbon':
    cwd         => "${::graphite::params::carbon_dl_loc}/carbon-${::graphite::params::carbonVersion}",
    command     => "install /usr/local/bin/python setup.py --prefix=${::graphite::install_dir} --install-lib=${::graphite::params::install_dir}/lib",
  }
}