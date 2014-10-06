# Class graphite::ldap
# Used to configure LDAP for authentication - NOT USED
class graphite::ldap (
  $gr_use_ldap                  = false,
  $gr_ldap_uri                  = '',
  $gr_ldap_search_base          = '',
  $gr_ldap_base_user            = '',
  $gr_ldap_base_pass            = '',
  $gr_ldap_user_query           = '(username=%s)'
  ) {

  #configure LDAP
}