notice('MODULAR: backup_mysql.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')

file { ${backup_location}/mysql :
    ensure => directory
}
file {"${backup_location}/mysql/backup.sh":
    content => template("backup_mysql/backup.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
}

cron { 'backup_mysql':
  command => "${backup_location}/mysql/backup.sh",
  user    => 'root',
  minute  => '38',
  hour    => ['4','12','20'],
}

