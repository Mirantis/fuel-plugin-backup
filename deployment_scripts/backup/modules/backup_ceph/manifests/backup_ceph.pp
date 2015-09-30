notice('MODULAR: backup_ceph.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')

file { "$backup_location" :
    ensure => directory
}

file {"{$backup_location}/backup_ceph.sh":
    content => template("ceph_backup/backup_ceph.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
}
file {"${backup_location}/config":
    content => template("ceph_backup/config.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
}
file {"${backup_location}/functions":
    content => template("ceph_backup/functions.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
}
cron { 'backup_ceph':
  command => '/var/backups/backup_ceph.sh',
  user    => 'root',
  minute  => '38',
  hour    => ['4','12','20'],
}
