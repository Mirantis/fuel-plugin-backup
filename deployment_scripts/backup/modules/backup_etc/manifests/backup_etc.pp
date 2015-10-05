notice('MODULAR: backup_etc.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')
$backetc                  = pick($backup_hash['backetc'], false)

if $backetc {
  file { "${backup_location}" :
    ensure => directory
  } ->
  file { "${backup_location}/etc" :
    ensure => directory
  }

  file {"${backup_location}/etc/backup_etc.sh":
    content => template("backup_etc/backup_etc.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  cron { 'backup_etc':
    command => "${backup_location}/etc/backup_etc.sh",
    user    => 'root',
    minute  => '38',
    hour    => '6',
  }
}