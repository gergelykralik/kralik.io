---
title: Backing up your server to Amazon AWS
intro: Backups are key, here is how to easily backup your server to S3, with duplicity and duplicity-backup.
tags:
  - server
  - backup
date: 2017-07-17 12:27:07
---

**Backups are key**, here is how to easily backup your server to *S3*, with duplicity and duplicity-backup. Please be aware that **cloud storages are not entirely private** and ***encryption*** is also needed. With this approach you will have **encrypted automatic backups** of your files.

In this tutorial I'm using a `CentOS` server. First you will need to install `duplicity`, `s3cmd`.

Run these commands as `root` or alternatively prefix the commands with `sudo`.

```bash
yum install -y duplicity s3cmd
```

Next install [duplicity-backup.sh](https://github.com/zertrin/duplicity-backup.sh). Then copy the sample config file to `/etc/duplicity-backup.conf`.

```bash
cd /usr/local/etc
git clone https://github.com/zertrin/duplicity-backup.git
cd duplicity-backup
cp duplicity-backup.conf.example /etc/duplicity-backup.conf
```

Edit the config file

```bash
...
AWS_ACCESS_KEY_ID="[key-id]"
AWS_SECRET_ACCESS_KEY="[secret-key]"

...

PASSPHRASE="[gpg-pass]"
GPG_ENC_KEY="[gpg-encryption-key]"
GPG_SIGN_KEY="[gpg-signing-key]"

...

ROOT="/"

...

DEST="s3://[bucket-region].amazonaws.com/[bucket-name]/[folder/]"

...

INCLIST=("/backups/mysql" \
         "/www/[your/path]" \
)

EXCLIST=("/www/[excluded]" )

...

LOGDIR="/var/log/duplicity-backup/"
LOG_FILE="duplicity-`date +%Y-%m-%d_%H-%M`.txt"
LOG_FILE_OWNER="[group]:[user]"


```

In the last part of the config file you can configure notifications, it's super useful, please do so.

Create a folder for the logs if it does not exist

```bash
mkdir -p /var/log/duplicity-backup
```

You are all set to create your first backup to S3!

```bash
/usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup.conf -b
```

Configure a cron entry to do the backup procedure automatically

```bash
crontab -e 
```

Add the entry (this will run at 04:04 Monday, Wednesday and Friday)

```bash
04 04 * * 1,3,5 /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup.conf -b
```

After setting all things up you *should* back up the **configuration and the gpg keys** in case of server failure, because without the keys and the pass you won't get your files back. Use the `--backup-config` parameter to create a symmetrically encrypted tar of the config and keys. *Please save it to a safe place.*


