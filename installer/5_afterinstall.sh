#enable pipewire for user
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire.socket pipewire-pulse.socket
systemctl --user --now disable pipewire-media-session.service
systemctl --user --force enable wireplumber.service

#enable nvidia-powerd
sudo systemctl enable nvidia-powerd.service
sudo systemctl start nvidia-powerd.service

sudo emerge --ask \
app-crypt/veracrypt \
mail-client/thunderbird-bin \
media-fonts/fontawesome \
net-im/discord \
gui-apps/grim \
gui-apps/slurp \
gui-wm/gamescope \
kde-apps/kio-extras \
net-misc/yt-dlp

#flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.usebottles.bottles
flatpak install flathub com.github.tchx84.Flatseal
