#
class profile_pulp (
  Boolean $manage_repo,
) {
  if $manage_repo {
    include pulpcore::repo
  }

  class { 'pulpcore':
    apache_http_vhost  => true,
    apache_https_vhost => false,
  }
}
