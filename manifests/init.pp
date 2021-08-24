#
class profile_pulp (
  Boolean               $manage_repo,
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
    include pulpcore::repo
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
  include profile_pulp::cli

  class { 'pulpcore':
    apache_http_vhost  => false,
    apache_https_vhost => false,
  }

  $plugins.each |$plugin| {
    class { "pulpcore::plugin::${plugin}": }
  }

  include profile_pulp::helperscripts

  $_pulpcoreapi_config = {
    'servername'     => $servername,
    'admin_username' => keys($apache_basicauth)[0],
    'admin_password' => values($apache_basicauth)[0],
  }

  file { '/etc/puppetlabs/puppet/pulpcoreapi.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => epp("${module_name}/pulpcoreapi.yaml.epp", $_pulpcoreapi_config),
  }
}
