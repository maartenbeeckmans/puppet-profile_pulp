#
#
# Basicauth parameter: if any usernames then admin are added,
# the username should also be added in table
class profile_pulp::apache (
  String        $servername           = $::profile_pulp::apache_servername,
  Array[String] $serveraliases        = $::profile_pulp::apache_serveraliases,
  String        $docroot              = $::profile_pulp::apache_docroot,
  Hash          $docroot_directory    = $::profile_pulp::apache_docroot_directory,
  Hash          $content_directory    = $::profile_pulp::apache_content_directory,
  Hash          $api_directory        = $::profile_pulp::apache_api_directory,
  Hash          $api_directory_status = $::profile_pulp::apache_api_directory_status,
  Hash          $proxy_pass_static    = $::profile_pulp::apache_proxy_pass_static,
  Hash          $basicauth            = $::profile_pulp::apache_basicauth,
) {
  class { 'profile_apache': }

  profile_apache::vhost { 'pulpcore':
    ensure            => present,
    servername        => $servername,
    serveraliases     => $serveraliases,
    port              => 80,
    docroot           => $docroot,
    manage_docroot    => false,
    directories       => [$docroot_directory, $content_directory],
    manage_sd_service => false,
  }

  profile_apache::vhost { 'pulpcore-https':
    ensure            => present,
    servername        => $servername,
    serveraliases     => $serveraliases,
    ssl               => true,
    port              => 443,
    docroot           => $docroot,
    manage_docroot    => false,
    directories       => [$docroot_directory, $content_directory, $api_directory, $api_directory_status],
    proxy_pass        => [$proxy_pass_static],
    manage_sd_service => false,
  }

  file { '/var/lib/pulp/pulpcore_static':
    ensure => directory,
    owner  => $::pulpcore::user,
    group  => $::pulpcore::group,
  }

  file { '/etc/httpd/pulpcore.htpasswd':
    content => join(join_keys_to_values($basicauth, ':'), "\n"),
    owner   => $::apache::user,
    mode    => '0400',
  }
}
