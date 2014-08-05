class graphite::webserver::uwsgi {

  package { 'uwsgi':
    provider => 'pip',
    ensure   => 'installed',
  }
}