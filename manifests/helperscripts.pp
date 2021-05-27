#
#
#
class profile_pulp::helperscripts (
  String $servername = $::profile_pulp::apache_servername,
) {
  $_helperscripts = [ 'pcurlg', 'pcurlp', 'pcurlf', 'pulp_clean_orphans' ]

  $_config = {
    'api_address' => $servername,
    'api_port'    => 443,
  }

  $_helperscripts.each | $script | {
    file { "/usr/bin/${script}":
      ensure  => present,
      mode    => '0755',
      content => epp("${module_name}/bin/${script}", $_config),
    }
  }
}
