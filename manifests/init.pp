#
class profile_pulp (
  Boolean $manage_repo,
  Boolean $manage_firewall_entry,
  Boolean $manage_sd_service,
  Boolean $manage_apache,
  String  $sd_service_name,
  Array   $sd_service_tags,
  String  $data_device,
  Array   $plugins,
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
    device => $data_device,
    mkdir  => false,
    before => Class['Pulpcore'],
  }

  include pulpcore

  if $manage_apache {
    include profile_pulp::apache
  }

  if $manage_firewall_entry {
    firewall { '00080 allow pulpcore http':
      dport  => 80,
      action => 'accept',
    }
    firewall { '00443 allow pulpcore https':
      dport  => 443,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http            => 'https://localhost:443/pulp/api/v3/status/',
          interval        => '10s',
          tls_skip_verify => true,
        }
      ],
      port   => 443,
      tags   => $sd_service_tags,
    }
  }

  $plugins.each |$plugin| {
    class { "pulpcore::plugin::${plugin}": }
  }
}
