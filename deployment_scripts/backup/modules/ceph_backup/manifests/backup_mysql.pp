notice('MODULAR: backup_mysql.pp')

file {"/var/backups":
    ensure => directory
}
file {"/var/backups/backup.sh":
    content => template("cron/backup.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
}

cron { 'backup':
  command => '/var/backups/backup.sh',
  user    => 'root',
  minute  => '38',
  hour    => ['4','12','20'],
}

