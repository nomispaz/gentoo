#enable pipewire for user
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire.socket pipewire-pulse.socket
systemctl --user --now disable pipewire-media-session.service
systemctl --user --force enable wireplumber.service

#flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.tchx84.Flatseal

#firewalld
sudo firewall-cmd --set-default-zone block
sudo systemctl restart firewalld.service

#virusscanner
sudo freshclam

# sddm set theme to breeze
sudo kwriteconfig6 --file /etc/sddm.conf --group Theme --key Current breeze
