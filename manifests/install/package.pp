# == Class: graphite::install::packages
#
# This class installs graphite packages via pip
#
# === Parameters
#
# None.
#
class graphite::install::package {

  # see https://github.com/graphite-project/carbon/issues/86
  $carbon_pip_hack_source = "/usr/lib/python2.7/dist-packages/carbon-${graphite::carbon_version}-py2.7.egg-info"
  $carbon_pip_hack_target = "/opt/graphite/lib/carbon-${graphite::carbon_version}-py2.7.egg-info"
  $gweb_pip_hack_source = "/usr/lib/python2.7/dist-packages/graphite_web-${graphite::carbon_version}-py2.7.egg-info"
  $gweb_pip_hack_target = "/opt/graphite/webapp/graphite_web-${graphite::carbon_version}-py2.7.egg-info"

  package{'graphite-web':
    ensure   => $graphite::graphite_version,
  }->
  package{'carbon':
    ensure   => $graphite::carbon_version,
  }->
  package{'whisper':
    ensure   => $graphite::whisper_version,
  }->

  # workaround for unusual graphite install target:
  # https://github.com/graphite-project/carbon/issues/86
  file { $carbon_pip_hack_source :
    ensure => link,
    target => $carbon_pip_hack_target,
  }->
  file { $gweb_pip_hack_source :
    ensure => link,
    target => $gweb_pip_hack_target,
  }

}
