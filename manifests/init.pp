# == Class: logrhythm
#
# Full description of class logrhythm here.
#
class logrhythm (
  $logrhythm_server = "10.1.112.20",
  $logrhythm_port   = "443",
){

  package { 'scsm':
    ensure => installed,
  }

  service { 'scsm':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package['scsm'],
  }

  # This ini file is eventually modified by logrhythm directly.  We only want to do the inital modifications to it
  # and update it when the server changes.  The file manifest and exec are an ugly but necessary hack.
  file { 'logrhythm_scsm_ini':
    ensure  => file,
    path    => "/opt/logrhythm/scsm/config/scsm.ini.puppet",
    content => template('logrhythm/scsm.ini.erb'),
    notify  => Exec['make_scsm_ini_live'],
  }

  exec { 'make_scsm_ini_live':
    command     => "/bin/cp -f /opt/logrhythm/scsm/config/scsm.ini.puppet /opt/logrhythm/scsm/config/scsm.ini",
    refreshonly => true,
    notify      => Service['scsm'],
  }

  firewall { '100_3333_for_logrhythm':
    source  => "$logrhythm_server",
    proto   => 'tcp',
    action  => 'accept',
  }

}
