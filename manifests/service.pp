# == Class graphite::service
#
# This class is meant to be called from graphite
# It ensure the service is running
#
class graphite::service {

  service { $graphite::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ File["${graphite::install_dir}/conf/carbon.conf"],
                    File["${graphite::install_dir}/conf/relay-rules.conf"],
                    File["${graphite::install_dir}/conf/storage-schemas.conf"],
                  ],
  }
}
