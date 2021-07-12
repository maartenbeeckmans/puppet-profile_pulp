#
class profile_pulp (
  Boolean               $manage_repo,
  Pattern['^\d+\.\d+$'] $version,
  Boolean               $manage_firewall_entry,
  Boolean               $manage_sd_service,
  Array                 $sd_service_tags,
  String                $pulp_data_device,
  String                $postgres_data_device,
  String                $postgres_backup_device,
  Array                 $plugins,
  String                $apache_servername,
  Array[String]         $apache_serveraliases,
  String                $apache_docroot,
  Hash                  $apache_docroot_directory,
  Hash                  $apache_content_directory,
  Hash                  $apache_api_directory,
  Hash                  $apache_api_directory_status,
  Hash                  $apache_proxy_pass_static,
  Hash                  $apache_basicauth,
) {
  if $manage_repo {
    class { 'profile_pulp::repo':
      before => Class['Pulpcore'],
    }
  }

  exec { '/var/lib/pulp':
    path    => $::path,
    command => 'mkdir -p /var/lib/pulp',
    unless  => 'test -d /var/lib/pulp',
  }
  ~> profile_base::mount{ '/var/lib/pulp':
    device => $pulp_data_device,
    mkdir  => false,
    before => Class['Pulpcore'],
  }

  class { 'profile_redis':
    bind                  => '127.0.0.1',
    manage_firewall_entry => false,
  }

  class { 'profile_postgres':
    data_device           => $postgres_data_device,
    backup_device         => $postgres_backup_device,
    manage_firewall_entry => false,
  }

  include profile_pulp::apache

  class { 'pulpcore':
    apache_http_vhost  => false,
    apache_https_vhost => false,
  }

  $plugins.each |$plugin| {
    class { "pulpcore::plugin::${plugin}": }
  }

  include profile_pulp::helperscripts
}
