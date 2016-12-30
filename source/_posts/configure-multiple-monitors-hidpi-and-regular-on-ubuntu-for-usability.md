---
title: Configure multiple monitors (HiDPI and regular) on Ubuntu for usability
intro: How to use a regular monitor with a HiDPI one on Ubuntu. With this command you can upscale the regular monitor to match the resulution of the higher monitor.
date: 2016-11-18 08:08:15
tags: ubuntu, resolution, hidpi, xrandr
---

I had some troubles using my regular full HD monitor alongside my HiDPI display in ubuntu. Tried using the built in text scaling functionality, but it only scaled up the text, and not the other elements. Ubuntu lacks the method of scaling up only one of the monitors effectively.

I'm using this code to scale up my regular monitor to match the resoultion of the HiDPI.

```
/usr/bin/xrandr --output eDP1 --auto --output HDMI1 --auto --panning 4320x2430+3200+0 --scale 2.25x2.25 --pos 3200x0
```

Obviously you will need to tweak these parameters to match your monitor's resolution.