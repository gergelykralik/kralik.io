---
title: OpenSSL sign CSR with SAN enabled
intro: How to sign a certificate with multiple embedded alternative hostnames.
date: 2016-11-07 14:50:06
tags: security, openssl
---

In this example I used the config file made in [this post](https://kralik.io/2016/11/02/openssl-ca-configuration), and a [CSR from this post](https://kralik.io/2016/11/07/openssl-generate-csr-with-san).


```
openssl x509 -days 3650 -CA certs/ca-root.pem -CAkey private/ca-root.key -req -in csr/example.com.csr -outform PEM -out certs/example.com.crt -CAserial serial -extfile <(cat conf/caconfig.cnf <(printf "[SAN]\nsubjectAltName=DNS:example.com,IP:127.0.1.1")) -extensions SAN
```

```
openssl x509 -days 3650 -CA certs/ca-root.pem \
	-CAkey private/ca-root.key -req -in csr/example.com.csr \
	-outform PEM -out certs/example.com.crt \
	-CAserial serial \
	-extfile <(cat conf/caconfig.cnf <(printf "[SAN]\nsubjectAltName=DNS:example.com,IP:127.0.1.1")) \
	-extensions SAN
```

You have the signed certificate with the alternative names in place.
