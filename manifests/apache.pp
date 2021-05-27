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
  Boolean       $manage_sd_service    = $::profile_pulp::manage_sd_service,
  Array         $sd_service_tags      = $::profile_pulp::sd_service_tags,
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
    manage_sd_service => $manage_sd_service,
    sd_check_uri      => 'pulp/content/',
    sd_service_tags   => $sd_service_tags,
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
    manage_sd_service => $manage_sd_service,
    sd_check_uri      => 'pulp/api/v3/status/',
    sd_service_tags   => $sd_service_tags,
  }

  file { '/var/lib/pulp/pulpcore_static':
    ensure => directory,
    owner  => $::pulpcore::user,
    group  => $::pulpcore::group,
  }

  $_basicauth_encrypted = $basicauth.map | $u, $p | {
    join([$u, join([':', apache::pw_hash($p)])])
  }

  file { "${::apache::confd_dir}/pulpcore.htpasswd":
    content => join($_basicauth_encrypted, '\n'),
    owner   => $::apache::user,
    mode    => '0400',
  }

  $_netrc_hash = {
    'servername'     => $servername,
    'admin_username' => keys($basicauth)[0],
    'admin_password' => values($basicauth)[0],
  }

  file { '/root/.netrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/netrc", $_netrc_hash),
  }
}
