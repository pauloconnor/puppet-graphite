# Class graphite::webserver::uwsgi
# Install uswgi
class graphite::webserver::uwsgi {

  package { 'uwsgi':
    ensure   => 'installed',
    provider => 'pip',
  }
}