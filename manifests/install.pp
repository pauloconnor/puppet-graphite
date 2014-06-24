# == Class: graphite::install
#
# This class installs graphite packages via pip
#
# === Parameters
#
# None.
#
class graphite::install(
  $django_tagging_ver = '0.3.1',
  $twisted_ver = '11.1.0',
  $txamqp_ver = '0.4',
) inherits graphite::params {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }


  package { 'python-pip':
    ensure => present,
    before => Package[$::graphite::params::graphitepkgs]
  }
  #->
  #Package {
  #  provider => 'pip',
  #  require  => Package['python-pip'],
  #}

  # for full functionality we need these packages:
  # madatory: python-cairo, python-django, python-twisted,
  #           python-django-tagging, python-simplejson
  # optinal: python-ldap, python-memcache, memcached, python-sqlite

  # using the pip package provider requires python-pip
  if ! defined(Package[$::graphite::params::python_dev_pkg]) {
    package { $::graphite::params::python_dev_pkg :
      provider => undef, # default to package provider auto-discovery
      before   => [
        Package['django-tagging'],
        Package['twisted'],
        Package['txamqp'],
      ]
    }
  }

  package { $::graphite::params::graphitepkgs :
    ensure   => 'installed',
    provider => undef, # default to package provider auto-discovery
  }->
  package{'django-tagging':
    ensure   => $django_tagging_ver,
    provider => 'pip',
  }->
  package{'Twisted':
    ensure   => $twisted_ver,
    provider => 'pip',
  }->
  package{'txAMPQ':
    ensure   => $txamqp_ver,
    provider => 'pip',
  }

  if $graphite::use_packages == true {
    include graphite::install::package
  } else {
    include graphite::install::source
  }
  

}
