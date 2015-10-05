notice('MODULAR: backup_ceph.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')
$backceph                 = pick($backup_hash['backceph'], false)

if $backceph {
  file { "$backup_location" :
    ensure => directory
  } ->
  file { "${backup_location}/ceph" :
    ensure => directory
  } ->
  file { "${backup_location}/ceph/backup_ceph/" :
    ensure => directory
  }

  file {"${backup_location}/ceph/backup_ceph.sh":
    content => template("backup_ceph/backup_ceph.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file {"${backup_location}/ceph/backup_ceph/config":
    content => template("backup_ceph/config.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file {"${backup_location}/ceph/backup_ceph/functions":
    content => template("backup_ceph/functions.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  cron { 'backup_ceph':
    command => '/var/backups/ceph/backup_ceph.sh',
    user    => 'root',
    minute  => '48',
    hour    => '5',
  }
}