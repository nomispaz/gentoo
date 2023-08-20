#enable pipewire for user
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire.socket pipewire-pulse.socket
systemctl --user --now disable pipewire-media-session.service
systemctl --user --force enable wireplumber.service

