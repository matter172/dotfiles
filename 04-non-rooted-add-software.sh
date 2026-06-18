curl -f https://zed.dev/install.sh | sh

# Add to ~/.bashrc for future sessions
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc

# Also set it for the remainder of this script
export PATH="$HOME/.local/bin:$PATH"

pipx install gnome-extensions-cli --system-site-packages

gext install tilingshell@ferrarodomenico.com

flatpak install -y \
	com.brave.Browser \
	com.github.tchx84.Flatseal \
	com.valvesoftware.Steam \
	com.vysp3r.ProtonPlus \
	com.heroicgameslauncher.hgl \
	com.belmoussaoui.Decoder \
	io.github.nozwock.Packet \
	com.discordapp.Discord
