class graphite::webapp (  
  $django_1_4_or_less             = false,
  $django_db_engine               = 'django.db.backends.sqlite3',
  $django_db_name                 = '/opt/graphite/storage/graphite.db',
  $django_db_user                 = '',
  $django_db_password             = '',
  $django_db_host                 = '',
  $django_db_port                 = '',
  $webapp_cluster_enable          = false,
  $webapp_cluster_servers         = '[]',
  $webapp_cluster_fetch_timeout   = 6,
  $webapp_cluster_find_timeout    = 2.5,
  $webapp_cluster_retry_delay     = 60,
  $webapp_cluster_cache_duration  = 300,
  $webapp_memcache_hosts          = undef,
  $webapp_secret_key              = 'UNSAFE_DEFAULT',
  $webapp_nginx_htpasswd          = undef,
  $webapp_manage_ca_certificate   = true,
  $webapp_use_remote_user_auth    = 'False',
  $webapp_remote_user_header_name = undef,
  $web_server                     = 'apache',
  $web_servername                 = $::fqdn,
  $web_cors_allow_from_all        = false,
  
  ) {

  # install && conf webapp

}