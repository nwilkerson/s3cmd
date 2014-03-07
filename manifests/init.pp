define s3cmd::backup (
  $client,
  $s3_bucket,
  $backup_path,
  $week_keep = 4,
  $month_keep = 4,
  $cron_minute  = 0,
  $cron_hour    = 0,
)
{

  class { 's3cmd' : }

  file { "s3_backup_$name" :
    ensure  => present,
    mode    => 0755,
    owner   => root,
    group   => root,
    path    => "/usr/local/bin/s3_backup_$name",
    content => template('s3cmd/s3_backups.erb'),
  }

  cron { "s3_backup_cron_$name" :
    ensure  => present,
    command => "/usr/local/bin/s3_backup_$name",
    user    => $s3cmd::configure::s3_backup_user,
    hour    => $cron_hour,
    minute  => $cron_minute,
  }
}

class s3cmd::configure (
  $s3_backup_user,
  $aws_key,
  $aws_secret_key,
  $use_https,
  ) {

  file { 's3cmd_config' :
    ensure  => present,
    mode    => 0600,
    owner   => $s3_backup_user,
    group   => $s3_backup_user,
    path    => "/home/$s3_backup_user/.s3cfg",
    content => template('s3cmd/s3cfg.erb'),
    require => User["$s3_backup_user"],
  }

  user { "$s3_backup_user" :
    ensure  => present,
    home    => "/home/$s3_backup_user/",
    managehome => true,
  }
}

class s3cmd::install {
  Exec {
    unless => "/usr/bin/test -f /usr/local/bin/s3cmd",
    cwd    => "/usr/local/src",
  }

  exec { 'download-s3cmd' :
    command => '/usr/bin/wget -q https://github.com/s3tools/s3cmd/blob/master/s3cmd',
    timeout => 120,
  }

  file { '/usr/local/bin/s3cmd' :
    ensure => present,
    mode    => 0755,
    owner    => root,
    group   => root,
    require => Exec['download-s3cmd'],
  }

}

class s3cmd (
  $backup_user  = 'backuppc_s3',
  $use_https = yes,
){
  if $::s3_backup_user != undef {
    $t_backup_user = $::s3_backup_user
  } else {
    $t_backup_user = $backup_user
  }
  if $::s3_use_https != undef {
    $t_use_https  = $::s3_use_https
  } else {
    $t_use_https  = $use_https
  }

  class { 's3cmd::install' : }
  class { 's3cmd::configure' :
    s3_backup_user =>  $t_backup_user,
    aws_key        =>  $::s3_aws_key ,
    aws_secret_key =>  $::s3_aws_secret_key ,
    use_https      =>  $t_use_https
  }
}