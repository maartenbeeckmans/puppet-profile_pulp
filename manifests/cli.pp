#
#
#
class profile_pulp::cli (
  String $servername = $::profile_pulp::apache_servername,
  Hash   $basicauth  = $::profile_pulp::apache_basicauth,
) {
  package { 'python3-pulp-cli':
    ensure => 'installed',
  }

  $_config = {
    'servername'     => $servername,
    'admin_username' => keys($basicauth)[0],
    'admin_password' => values($basicauth)[0],
  }

  exec { '/root/.config/pulp':
    path    => $::path,
    command => 'mkdir -p /root/.config/pulp',
    unless  => 'test -d /root/.config/pulp',
  }
  -> file { '/root/.config/pulp/settings.toml':
    ensure  => present,
    mode    => '0755',
    content => epp("${module_name}/cli_settings.toml.epp", $_config),
  }

  file { '/etc/profile.d/pulp.sh':
    ensure  => file,
    mode    => '0644',
    content => 'eval "$(_PULP_COMPLETE=source_bash pulp)"',
  }
}
