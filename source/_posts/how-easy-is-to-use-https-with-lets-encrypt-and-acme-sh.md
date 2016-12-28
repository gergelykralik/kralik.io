---
title: How easy is to use HTTPS with Let's encrypt and acme.sh
intro: Probably the most easy way to set up your https certificates with working auto renewal using Acme.sh client to generate certificates from Let's encrypt.
date: 2016-11-26 20:00:35
tags: howto, security, apache, nginx
---

C'mon it's the end of 2016, if you don't use https you really should now. It's free, you only need to set it up once, and the rest is automated.

Let's get started. We will use a lightweight client called [Acme.sh](https://acme.sh/) to get the certificates. The official client from [Let's encrypt](https://letsencrypt.org/) is a bit bulky and has a lot of dependencies.

### Start with installing the [Acme.sh](https://acme.sh/) client

```sh
git clone https://github.com/Neilpang/acme.sh.git
cd acme.sh
./acme.sh --install  \
--home ~/myacme \
--certhome  ~/ssh/certs \
--accountemail  "hello@kralik.io"
```

You should set up your account with an email address, so you won't miss the notifications from Let's encrypt.

### Configue the `cron` job (optional)

The instaler script automatically sets up the cron job on your system, it's time to configure it. 

Enter the following command: `crontab -e`

Set the script to run at a random hour and minute to minimize the chance of `API` unreachability.

### Set up your webserver to use a virtual `document root` for the client

Create a directory writable by your webserver. You will use this directory to generate the authentication requests.
In this tutorial we will use `/var/www/acme`.

```sh
mkdir /var/www/acme
mkdir /var/www/acme/.well-known
mkdir /var/www/acme/.well-known/acme-challenge
```

#### Apache

Edit your main config file and add this alias:

```Apache
Alias /.well-known/acme-challenge/ /var/www/acme/.well-known/acme-challenge/
<Directory "//var/www/acme/.well-known/acme-challenge/">
    Options None
    AllowOverride None
    ForceType text/plain
    RedirectMatch 404 "^(?!/\.well-known/acme-challenge/[\w-]{43}$)"
</Directory>
```

Restart apache and you are ready to request your certificate.

#### Nginx

Add theses lines to your server block:

```Nginx
location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    root /var/www/acme/;
    break;
}

```

Restart Nginx and you are ready to request your certificate.

### Request and install a certificate

You can request a certificate for multiple hostnames hosted on the same server with this approach.

```
acme.sh --issue -d kralik.io -d www.kralik.io -w /var/www/acme
```

**Now you have your certificate!**

### Install the certificate

```sh
acme.sh --installcert -d kralik.io \
        --certpath "/new/path/to/cert/server.cer" \
        --keypath "/new/path/to/cert/server.key" \
        --capath "/new/path/to/cert/ca.cer" \
        --fullchainpath "/new/path/to/cert/fullchain.cer" \
        --reloadcmd "systemctl nginx/apache2 reload"
```

After issuing this command the client will know which script to run after certificate renewal.

**Update:** *The install script was updated with configuration allowing to copy the generated certificates from the default folder to some place else. It is advised by [acme.sh](https://acme.sh) to do so, because the default location also contains other important internal files of the script and its structure is subject to change.*
