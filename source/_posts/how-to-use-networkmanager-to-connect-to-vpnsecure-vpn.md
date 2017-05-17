---
title: How to use NetworkManager to connect to VPNSecure VPN service
intro: I've made an updated script to automatically generate NetworkManager config for the VPN service offered by VPNSecure.me. They recently discontinued to support this method in favor their "desktop client", so here is the tested out and working generator.
date: 2017-05-13 12:12:12
tags: how to, vpn, vpnsecure, sh
---

VPNSecure.me offers a much needed service, to enhance your privacy. You can download the official (and somewhat buggy, Electron based) app, or you can configure the NetworkManager to serve up all the available servers to connect to.

They have an entry to achieve this on the support page, but outdated, and not working correctly. Check out my version, which is partially based off the original found at support.vpnsecure.me.

**Prerequisites:** ***open the script, modify the config options to match your system, then you're good to go. Of course you will need to have a valid subscription to the VPNSecure.me service.***

The script generates a configuration file for all the available VPN servers and places them to the `NetworkManager` default config location, then reloads the settings.

You need to set your `username`, this is the bare minimum. You will be prompted for your `password`. (The credentials are used to retrieve the server list).

<script src="https://gist.github.com/gergelykralik/6af35fafd81d7152ee9ea4b542774c9f.js"></script>
