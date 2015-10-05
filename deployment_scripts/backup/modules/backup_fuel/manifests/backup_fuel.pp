notice('MODULAR: backup_fuel.pp')

$backup_hash              = hiera_hash('backup', {})
$backup_location          = pick($backup_hash['backup_location'], '/var/backups')
$numtokeep                = pick($backup_hash['numtokeep'], '7')
$backfuel                 = pick($backup_hash['backfuel'], false)

if $backfuel {
  file { "${backup_location}" :
    ensure => directory
  } ->
  file { "${backup_location}/fuel" :
    ensure => directory
  }

  file {"${backup_location}/fuel/backup_fuel.sh":
    content => template("backup_fuel/backup_fuel.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  cron { 'backup_fuel':
    command => "${backup_location}/fuel/backup_fuel.sh",
    user    => 'root',
    minute  => '38',
    hour    => '7',
  }
}