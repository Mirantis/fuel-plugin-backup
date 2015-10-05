notice('MODULAR: backup_mysql.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')
$backmysql                = pick($backup_hash['backmysql'], false)

if $backmysql {
  file { "${backup_location}" :
    ensure => directory
  } ->
  file { "${backup_location}/mysql" :
    ensure => directory
  }

  file {"${backup_location}/mysql/backup_mysql.sh":
    content => template("backup_mysql/backup_mysql.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  cron { 'backup_mysql':
    command => "${backup_location}/mysql/backup_mysql.sh",
    user    => 'root',
    minute  => '38',
    hour    => ['4','12','20'],
  }
}
