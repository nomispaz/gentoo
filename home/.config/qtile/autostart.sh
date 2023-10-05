#!/usr/bin/env bash

### AUTOSTART PROGRAMS ###
wl-clipboard-history -t &
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=qtile &
/usr/libexec/polkit-gnome-authentication-agent-1 &
swaybg -m fill -i ~/Pictures/1920x1080_px_forest-1262037.jpg &
nm-applet --indicator &
