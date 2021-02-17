#
#
#
class profile_pulp::apache {
  class { 'openssl':
    package_ensure         => present,
    ca_certificates_ensure => present,
  }

  openssl::certificate::x509 { 'pulpcore':
    country      => 'BE',
    organization => $facts['networking']['domain'],
    commonname   => $facts['networking']['fqdn'],
  }
}
