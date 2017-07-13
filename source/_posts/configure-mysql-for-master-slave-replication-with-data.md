---
title: Configure MySQL for master/slave replication with data
intro: How to configure MySQL master/slave replication with data already on the main server. Step by step instructions.
date: 2016-11-15 08:15:22
tags:
  - how to
  - mysql
---

Recently I had to reconfigure our production database server, and had to set up MySQL for master/slave replication. The process is not too hard, but you need to keep in mind that at the time of starting the replication process you need to have identical data on both of the servers.

I started with a blank server and a server with our databases (several millions of rows). The most convenient way I found to lock out access from the server with data is to restart the server on a non-standard port, also to move the location of the socket. This is useful, because you can then dump all the data to a file, and no need to worry about changes.

### Step 1 - Dump the data from the main server to a file

I used mysqldump to make a copy of all the databases on the main server, then rsync'd the dump to the new server. In my case I wanted to sync all of the databases. *This post assumes you want to sync all.*

```
mysqldump --skip-opt --all-databases --allow-keywords --comments \
	--complete-insert --create-options --default-character-set=utf8 \
    --extended-insert --flush-logs --force --host="localhost" --lock-all-tables \
    --password="*mysqlpass*" --port="*mysqlport*" --protocol=TCP --quick \
    --quote-names --set-charset --triggers --tz-utc --user="*mysqlusr*" > "/path/to/dump.sql"
```


### Step 2 - Import the data on the new server

If you have a large dataset (mine was over 6 GB) your server needs some tweaking to be able to import the data in reasonable time. You need to adjust the buffers and disable InnoDB double write. These are the values I used:

```
innodb_buffer_pool_size = 25G
innodb_log_buffer_size = 256M
innodb_log_file_size = 1G
innodb_write_io_threads = 16
innodb_flush_log_at_trx_commit = 0

```

The value of the buffer pool size can't be larger than the amount of RAM you have.
Finally restart mysql server with disabled double write, import the dump and restart MySQL again to re-enable the double write:


```
service mysql restart --innodb-doublewrite=0
mysql -u*mysqlusr* -p < /path/to/dump.sql
service mysql restart
```


### Step 3 - Configure the servers for replication

You need to edit the `my.cnf` on both of the servers.

##### Master

```
[mysqld]
server_id=1
log_bin=/path/to/mysql/bin-log
log_error=/path/to/mysql/mysql-bin.err
binlog_cache_size=262144
expire_logs_days=10
innodb_flush_log_at_trx_commit=1
sync_binlog=1
```

##### Slave

```
[mysqld]
server_id=2
relay_log=/path/to/mysql/relay-bin.log
log_bin=/path/to/mysql/slave-bin-log
```

You can find the explanation on each value in the documentation.


### Step 4 - Start replication

Create the replication user on Master:

```
CREATE USER 'replication_sl'@'%' IDENTIFIED BY '*password*';
GRANT REPLICATION SLAVE ON *.* TO 'replication_sl'@'%';
```

Then read the `master position` using this query

```
mysql> SHOW MASTER STATUS;
```

Now you need to configure the slave (using the values from the previous query on the master):

```
CHANGE MASTER TO MASTER_HOST='*slave IP*',MASTER_USER='replication_sl', MASTER_PASSWORD='*password*', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=*position*;
```

Start the slave and check status:

```
START SLAVE;
SHOW SLAVE STATUS \G;
```

That's all. You have your MySQL master/slave replication set up.
