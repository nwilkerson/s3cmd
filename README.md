s3cmd
=====

s3cmd and backup script

This module installes the program s3cmd to your server. It also comes with a backup module that allows you to quickly set cron jobs to backup directories to an s3 bucket. 

class sample::backuppc_s3 {

  s3cmd::backup { 'job-name' :
    client  =>  'sample-server',
    s3_bucket => 's3_bucket',
    backup_path =>  'files-to-backup',
  }
}

See the manifest for full list of parameters. 
