---
title: OpenSSL generate CSR with alternative names
intro: With this command you can generate a certificate signing request with the alternative names already in the CSR.
date: 2016-11-07 14:49:58
tags: security, openssl
---

With this command you can generate a certificate signing request with the alternative names already in the CSR. If you want to add domain names use `DNS:example.com`, if you want to add IP address use this format: `IP:127.0.1.1`. You can add as many alternativa names as you wish, as separator use a comma.

In this example I used the config file made in [this post](https://kralik.it/2016/11/02/openssl-ca-configuration).


```
openssl req -new -config conf/caconfig.cnf -keyform PEM -keyout private/example.com.key -reqexts SAN -config <(cat conf/caconfig.cnf <(printf "[SAN]\nsubjectAltName=DNS:example.com,IP:127.0.1.1")) -outform PEM -out csr/example.com.csr -nodes
```

```
openssl req -new -config conf/caconfig.cnf \
	-keyform PEM -keyout private/example.com.key \
	-reqexts SAN \
	-config <(cat conf/caconfig.cnf <(printf "[SAN]\nsubjectAltName=DNS:example.com,IP:127.0.1.1")) \
	-outform PEM \
	-out csr/example.com.csr \
	-nodes
```

See my [next post on how to sign this CSR](https://kralik.it/2016/11/07/openssl-sign-csr-with-san).
