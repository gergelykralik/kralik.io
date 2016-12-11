---
title: Self hosted Firefox Sync server, how to sync with Android
intro: Recently I tried to run my own Firefox Sync server. It's really great to own your content, but often you have hard time figuring things out. Here is how to set up the server to sync with Android devices.
date: 2016-12-11 14:42:28
tags: self-hosted, how to, firefox, sync
---

Recently I tried the self-hosted version of [Firefox Sync](https://www.mozilla.org/en-US/firefox/sync/). Mozilla complicates the things a little, because you need to install two services to make it fully self-hosted:

  + [Sync server](https://docs.services.mozilla.com/howtos/run-sync-1.5.html)
  + [Account server](https://docs.services.mozilla.com/howtos/run-fxa.html)


Setting up the Account server is more complicated, you can use your Sync server with your account stored on Mozilla's account server. Your content will be saved on the Sync server only, so your data and privacy are safe.

## Installing the Sync server

You will need Python 2.7, virtualenv, common packages to build your server, and of course a web server, Apache with mod wsgi or Nginx with gunicorn.

The process itself is pretty straightforward, [check out the documentation on mozilla.com](https://docs.services.mozilla.com/howtos/run-sync-1.5.html)

I used a public subdomain to set up the server, in this case just omit the port number and use the domain. Configure the path to the sqlite database. Of course you can use other databases too, but `MySQL` seems a bit of overkill for the task, but is you plan to make your server available for multiple people, you should consider upgrading. 

Here is the relevant part form the file `syncserver.ini`

```
[syncserver]
public_url = https://sync.example.com/
sqluri = sqlite:////path/to/database/file.db
secret = .... secret ....
allow_new_users = true
```

Next, edit the `syncserver.wsgi` file, set the `/full/path/to/syncserver.ini`. *After successfully connecting your account to your server you can disable the `allow_new_users` parameter.*

### Running behind Apache webserver

Cerate a virtual host. You can dedicate a whole subdomain for sync, or run it in a subfolder, in the latter case you probably have a virtual host, it should work if you set the aliases correctly.

```Apache
<Directory /path/to/syncserver>
  Require all granted
</Directory>
<VirtualHost *:443>
  ServerName sync.example.com
  DocumentRoot /path/to/syncserver
  WSGIProcessGroup sync
  WSGIDaemonProcess sync user=www-data group=www-data processes=2 threads=25 python-path=/path/to/syncserver/local/lib/python2.7/site-packages/
  WSGIPassAuthorization On
  WSGIScriptAlias / /path/to/syncserver/syncserver.wsgi

  LogLevel info
  CustomLog /var/log/apache2/sync.example.com-access.log combined
  ErrorLog  /var/log/apache2/sync.example.com-error.log
  ### SSL settings, certificates, options, etc. ###
</VirtualHost>
```

At first you should set the `LogLevel info` parameter, because the wsgi process logs to the apache error log, and it's much easier to figure out what's wrong is you see the error message. 

#### Manage the server

The server starts and stops with Apache, but you can restart the server simply by editing the `wsgi` file.

## Setting up Sync on desktop

Open your browser and head to `about:config` page, and search for the key `identity.sync.tokenserver.uri`

Replace the default address with your `public_url` and append the path `token/1.0/sync/1.5`.

```
identity.sync.tokenserver.uri: https://sync.example.com/token/1.0/sync/1.5
```

Now you can register an account with Sync, or you can use your existing account.

## Setting up Sync on Android

The documentation *does not* mention one really **important** detail about making Sync work on Android. You have to make available your server url without [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication). Basically you need to make the virtual host for sync as the default host on the server. Without this step **it will not work at all**.

*Alternatively you can try and set a custom port for Sync, but I'm not sure if it will work, it might, but on some networks custom ports are blocked.*

This seems really annoying, it's 2016, and **no SNI support?!** And not a mention of it in the documentation! If you are interested why there is no SNI support you can read about it on [bugzilla.mozilla.org](https://bugzilla.mozilla.org/show_bug.cgi?id=765064#c4). Basically they ship their own version of `Apache HTTP Client`, so not is only Sync affected, but other features too. [Source: bugzilla.mozilla.org](https://bugzilla.mozilla.org/show_bug.cgi?id=765064#c19)

##### Setup if you managed to make the host for sync work wothout SNI.

First `Disconnect` your account if you're signed in, then follow the exact same steps as on desktop. You can verify your custom server address after login, it will be shown in the Sync settings.