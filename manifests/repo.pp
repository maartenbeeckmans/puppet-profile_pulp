#
#
#
class profile_pulp::repo (
  Pattern['^\d+\.\d+$'] $version = $::profile_pulp::version,
) {
  $_config = {
    'version'   => $version,
    'dist_tag' => "el${facts['os']['release']['major']}",
  }

  file { '/etc/yum.repos.d/pulp.repo':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('profile_pulp/repo.epp', $_config),
  }
}
